import React, { useEffect, useState, useRef } from 'react';
import {
  listLibraryVideos,
  createUploadSession,
  startBunnyDirectTusUpload,
  getVideoStatus,
  getVideoDetail,
  linkVideoToLesson,
  unlinkVideoFromLesson,
  deleteBunnyVideo,
} from '../api/videos';
import { fetchAdminCourses, fetchAdminCourseDetail } from '../api/courses';
import { BunnyVideo, Course, Lesson } from '../types';
import { formatDuration, formatDate } from '../utils/format';
import { useToast } from '../context/ToastContext';
import {
  Video,
  UploadCloud,
  Link2,
  Unlink,
  Trash2,
  RefreshCw,
  Search,
  CheckCircle2,
  Clock,
  AlertCircle,
  Play,
  Layers,
  Info,
  Copy,
  ChevronLeft,
  ChevronRight,
  AlertTriangle,
  FileCheck,
} from 'lucide-react';
import { Badge } from '../components/Badge';
import { Modal } from '../components/Modal';
import { Button } from '../components/Button';
import { PageHeader } from '../components/PageHeader';
import { EmptyState } from '../components/EmptyState';
import { TableSkeleton } from '../components/LoadingSkeleton';

type UploadStage = 'idle' | 'preparing' | 'uploading' | 'processing' | 'ready' | 'error';

export const VideosPage: React.FC = () => {
  const toast = useToast();
  const [videos, setVideos] = useState<BunnyVideo[]>([]);
  const [totalVideos, setTotalVideos] = useState(0);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [serviceConfigured, setServiceConfigured] = useState<boolean | null>(null);

  // Upload Modal State
  const [isUploadOpen, setIsUploadOpen] = useState(false);
  const [uploadFile, setUploadFile] = useState<File | null>(null);
  const [videoTitle, setVideoTitle] = useState('');
  const [uploadStage, setUploadStage] = useState<UploadStage>('idle');
  const [uploadProgress, setUploadProgress] = useState<number>(0);
  const [uploadedBytes, setUploadedBytes] = useState<number>(0);
  const [totalBytes, setTotalBytes] = useState<number>(0);
  const [uploadStatusText, setUploadStatusText] = useState<string>('');
  const [uploadError, setUploadError] = useState<string | null>(null);
  const activeTusUploadRef = useRef<any>(null);
  const pollingIntervalRef = useRef<any>(null);

  // Video Details Modal
  const [selectedVideo, setSelectedVideo] = useState<BunnyVideo | null>(null);

  // Link Video Modal State
  const [linkingVideo, setLinkingVideo] = useState<BunnyVideo | null>(null);
  const [courses, setCourses] = useState<Course[]>([]);
  const [selectedCourseId, setSelectedCourseId] = useState<number | null>(null);
  const [courseLessons, setCourseLessons] = useState<Lesson[]>([]);
  const [selectedLessonId, setSelectedLessonId] = useState<number | null>(null);
  const [overwriteConflict, setOverwriteConflict] = useState(false);
  const [existingLessonVideoId, setExistingLessonVideoId] = useState<string | null>(null);
  const [linkSubmitting, setLinkSubmitting] = useState(false);
  const [linkError, setLinkError] = useState<string | null>(null);

  // Unlink / Delete Confirmation States
  const [unlinkingVideo, setUnlinkingVideo] = useState<BunnyVideo | null>(null);
  const [deletingVideo, setDeletingVideo] = useState<BunnyVideo | null>(null);
  const [actionSubmitting, setActionSubmitting] = useState(false);

  // Cleanup active polling on unmount
  useEffect(() => {
    return () => {
      if (pollingIntervalRef.current) clearInterval(pollingIntervalRef.current);
      if (activeTusUploadRef.current) activeTusUploadRef.current.abort();
    };
  }, []);

  const loadVideos = async () => {
    setLoading(true);
    try {
      const data = await listLibraryVideos({ page, per_page: 15, search: search || undefined });
      setVideos(data.videos || []);
      setTotalVideos(data.total || 0);
      setServiceConfigured(true);
    } catch (err: any) {
      if (err?.status === 503 || err?.message?.includes('not configured')) {
        setServiceConfigured(false);
      } else {
        toast.error('Failed to load video library', err?.message);
      }
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadVideos();
  }, [page]);

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setPage(1);
    loadVideos();
  };

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
    toast.info('Copied to Clipboard', text);
  };

  // --------------------------------------------------------------------------
  // 1. TUS DIRECT UPLOAD WORKFLOW
  // --------------------------------------------------------------------------
  const openUploadModal = () => {
    setUploadFile(null);
    setVideoTitle('');
    setUploadStage('idle');
    setUploadProgress(0);
    setUploadedBytes(0);
    setTotalBytes(0);
    setUploadError(null);
    setUploadStatusText('');
    setIsUploadOpen(true);
  };

  const handleCancelUpload = () => {
    if (activeTusUploadRef.current) {
      activeTusUploadRef.current.abort();
      activeTusUploadRef.current = null;
    }
    if (pollingIntervalRef.current) {
      clearInterval(pollingIntervalRef.current);
      pollingIntervalRef.current = null;
    }
    setIsUploadOpen(false);
    setUploadStage('idle');
  };

  const handleStartUpload = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!uploadFile) {
      setUploadError('Please select a valid video file to upload.');
      return;
    }
    const finalTitle = videoTitle.trim() || uploadFile.name.replace(/\.[^/.]+$/, '');

    setUploadError(null);
    setUploadStage('preparing');
    setUploadProgress(0);
    setUploadStatusText('Requesting short-lived upload authorization from server...');

    try {
      // Step A: Request short-lived TUS upload session from backend
      const session = await createUploadSession({ title: finalTitle });

      setUploadStage('uploading');
      setUploadStatusText('Streaming video chunks directly to Bunny CDN...');

      // Step B: Direct browser TUS upload
      const tusUpload = startBunnyDirectTusUpload(uploadFile, session, {
        onProgress: (bytesUp, bytesTot, percentage) => {
          setUploadedBytes(bytesUp);
          setTotalBytes(bytesTot);
          setUploadProgress(percentage);
          setUploadStatusText(`Uploading: ${percentage}% (${(bytesUp / (1024 * 1024)).toFixed(1)} MB / ${(bytesTot / (1024 * 1024)).toFixed(1)} MB)`);
        },
        onError: (err) => {
          console.error('TUS upload error:', err);
          setUploadStage('error');
          setUploadError(err.message || 'Direct upload to Bunny failed. Please check network connection.');
        },
        onSuccess: () => {
          setUploadProgress(100);
          setUploadStage('processing');
          setUploadStatusText('Upload complete! Transcoding & processing video on Bunny CDN...');

          // Step C: Poll video status until finished
          let attempts = 0;
          pollingIntervalRef.current = setInterval(async () => {
            attempts += 1;
            try {
              const statusData = await getVideoStatus(session.video_id);
              if (statusData.status === 'finished') {
                clearInterval(pollingIntervalRef.current);
                pollingIntervalRef.current = null;
                setUploadStage('ready');
                setUploadStatusText('Video is fully processed and ready for streaming!');
                toast.success('Video Uploaded & Ready', `"${finalTitle}" is live.`);
                setTimeout(() => {
                  setIsUploadOpen(false);
                  loadVideos();
                }, 1500);
              } else if (statusData.status === 'error' || statusData.status === 'upload_failed') {
                clearInterval(pollingIntervalRef.current);
                pollingIntervalRef.current = null;
                setUploadStage('error');
                setUploadError('Bunny CDN reported a transcoding failure for this file.');
              } else if (attempts > 30) {
                // Timeout polling after 2.5 minutes
                clearInterval(pollingIntervalRef.current);
                pollingIntervalRef.current = null;
                setUploadStage('ready');
                toast.info('Upload Completed', 'Video is still encoding on Bunny CDN.');
                setIsUploadOpen(false);
                loadVideos();
              }
            } catch (err: any) {
              console.error('Polling error:', err);
            }
          }, 5000);
        },
      });

      activeTusUploadRef.current = tusUpload;
    } catch (err: any) {
      setUploadStage('error');
      if (err?.status === 503) {
        setUploadError(
          'Bunny Stream is not configured on this backend server. Please configure BUNNY_API_KEY and BUNNY_LIBRARY_ID in backend .env.'
        );
      } else {
        setUploadError(err?.message || 'Failed to initiate video upload session.');
      }
    }
  };

  // --------------------------------------------------------------------------
  // 2. VIDEO DETAILS INSPECTION
  // --------------------------------------------------------------------------
  const openVideoDetail = async (video: BunnyVideo) => {
    setSelectedVideo(video);
    try {
      const fullDetail = await getVideoDetail(video.video_id);
      setSelectedVideo(fullDetail);
    } catch (err: any) {
      console.error('Failed to get full video detail:', err);
    }
  };

  // --------------------------------------------------------------------------
  // 3. LINK VIDEO TO LESSON
  // --------------------------------------------------------------------------
  const openLinkModal = async (video: BunnyVideo) => {
    setLinkingVideo(video);
    setLinkError(null);
    setSelectedLessonId(null);
    setOverwriteConflict(false);
    setExistingLessonVideoId(null);

    try {
      const data = await fetchAdminCourses();
      setCourses(data);
      if (data.length > 0) {
        setSelectedCourseId(data[0].id);
        const detail = await fetchAdminCourseDetail(data[0].id);
        setCourseLessons(detail.lessons || []);
        if (detail.lessons && detail.lessons.length > 0) {
          setSelectedLessonId(detail.lessons[0].id);
          setExistingLessonVideoId(detail.lessons[0].video_stream_id || null);
        }
      }
    } catch (err: any) {
      toast.error('Failed to load courses for linking', err?.message);
    }
  };

  const handleCourseChangeInModal = async (courseId: number) => {
    setSelectedCourseId(courseId);
    try {
      const detail = await fetchAdminCourseDetail(courseId);
      setCourseLessons(detail.lessons || []);
      if (detail.lessons && detail.lessons.length > 0) {
        setSelectedLessonId(detail.lessons[0].id);
        setExistingLessonVideoId(detail.lessons[0].video_stream_id || null);
      } else {
        setSelectedLessonId(null);
        setExistingLessonVideoId(null);
      }
    } catch (err: any) {
      toast.error('Failed to load lessons', err?.message);
    }
  };

  const handleLessonChangeInModal = (lessonId: number) => {
    setSelectedLessonId(lessonId);
    const lesson = courseLessons.find((l) => l.id === lessonId);
    setExistingLessonVideoId(lesson?.video_stream_id || null);
  };

  const handleLinkSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!linkingVideo || !selectedLessonId) return;

    setLinkSubmitting(true);
    setLinkError(null);
    try {
      await linkVideoToLesson(linkingVideo.video_id, selectedLessonId, overwriteConflict);
      toast.success(
        'Video Linked to Lesson',
        `"${linkingVideo.title}" is now attached to lesson.`
      );
      setLinkingVideo(null);
      await loadVideos();
    } catch (err: any) {
      if (err?.status === 409) {
        setLinkError(
          'Conflict: This lesson already has another video attached. Please check the overwrite box to replace it.'
        );
      } else {
        setLinkError(err?.message || 'Failed to link video to lesson.');
      }
    } finally {
      setLinkSubmitting(false);
    }
  };

  // --------------------------------------------------------------------------
  // 4. UNLINK VIDEO
  // --------------------------------------------------------------------------
  const handleUnlinkSubmit = async () => {
    if (!unlinkingVideo) return;
    setActionSubmitting(true);
    try {
      await unlinkVideoFromLesson(unlinkingVideo.video_id);
      toast.success('Video Unlinked', `"${unlinkingVideo.title}" removed from lesson.`);
      setUnlinkingVideo(null);
      await loadVideos();
    } catch (err: any) {
      toast.error('Failed to unlink video', err?.message);
    } finally {
      setActionSubmitting(false);
    }
  };

  // --------------------------------------------------------------------------
  // 5. DELETE VIDEO
  // --------------------------------------------------------------------------
  const handleDeleteSubmit = async () => {
    if (!deletingVideo) return;
    setActionSubmitting(true);
    try {
      await deleteBunnyVideo(deletingVideo.video_id, true);
      toast.success('Video Deleted', `"${deletingVideo.title}" permanently removed from Bunny CDN.`);
      setDeletingVideo(null);
      await loadVideos();
    } catch (err: any) {
      toast.error('Deletion Failed', err?.message);
    } finally {
      setActionSubmitting(false);
    }
  };

  const getStatusBadge = (status: BunnyVideo['status']) => {
    switch (status) {
      case 'finished':
        return (
          <Badge variant="success" size="sm" className="gap-1 items-center">
            <CheckCircle2 size={12} />
            <span>Ready</span>
          </Badge>
        );
      case 'processing':
      case 'transcoding':
        return (
          <Badge variant="info" size="sm" className="gap-1 items-center animate-pulse">
            <Clock size={12} />
            <span>Encoding</span>
          </Badge>
        );
      case 'uploaded':
        return (
          <Badge variant="purple" size="sm" className="gap-1 items-center">
            <FileCheck size={12} />
            <span>Uploaded</span>
          </Badge>
        );
      case 'error':
      case 'upload_failed':
        return (
          <Badge variant="danger" size="sm" className="gap-1 items-center">
            <AlertCircle size={12} />
            <span>Failed</span>
          </Badge>
        );
      default:
        return (
          <Badge variant="default" size="sm" className="gap-1 items-center">
            <Clock size={12} />
            <span>Created</span>
          </Badge>
        );
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <PageHeader
        title="Bunny Stream Video Hub"
        subtitle="Manage cloud video library, direct resumable TUS uploads, and lesson video associations"
        breadcrumbs={[{ label: 'Admin', href: '/' }, { label: 'Videos' }]}
        action={
          <div className="flex items-center gap-2.5">
            <button
              onClick={loadVideos}
              className="p-2 bg-white hover:bg-slate-50 border border-slate-200 rounded-lg text-slate-600 hover:text-slate-900 transition-colors shadow-2xs cursor-pointer"
              title="Refresh Video Library"
            >
              <RefreshCw size={15} />
            </button>
            <Button onClick={openUploadModal} leftIcon={<UploadCloud size={16} />}>
              Upload Video
            </Button>
          </div>
        }
      />

      {/* Service Credentials Warning Notice */}
      {serviceConfigured === false && (
        <div className="p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs flex items-start gap-3">
          <AlertTriangle size={18} className="text-amber-600 shrink-0 mt-0.5" />
          <div className="space-y-1">
            <p className="font-bold">Bunny Stream Credentials Notice</p>
            <p className="text-amber-800">
              The backend returned a 503 status: Bunny Stream credentials (<code>BUNNY_API_KEY</code> and <code>BUNNY_LIBRARY_ID</code>) are not yet configured in the backend environment.
              Video management UI is fully functional in preview mode and ready for production credentials.
            </p>
          </div>
        </div>
      )}

      {/* Search Bar */}
      <form
        onSubmit={handleSearchSubmit}
        className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-2xs flex items-center gap-3"
      >
        <div className="relative flex-1">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search videos in Bunny library by title..."
            className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs sm:text-sm focus:bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>
        <Button type="submit" variant="secondary" size="sm">
          Search
        </Button>
      </form>

      {/* Video List Table */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-2xs overflow-hidden">
        {loading ? (
          <TableSkeleton rows={5} />
        ) : videos.length === 0 ? (
          <EmptyState
            icon={Video}
            title="No videos found"
            description={
              search
                ? 'Try adjusting your search query.'
                : 'Upload video lessons directly to your Bunny Stream library using resumable TUS upload.'
            }
            actionLabel="+ Upload First Video"
            onAction={openUploadModal}
          />
        ) : (
          <div className="divide-y divide-slate-100">
            {videos.map((video) => (
              <div
                key={video.video_id}
                className="p-4 sm:px-6 flex flex-col md:flex-row md:items-center justify-between gap-4 hover:bg-slate-50/75 transition-colors"
              >
                {/* Left: Thumbnail & Info */}
                <div className="flex items-center gap-4 min-w-0">
                  {video.thumbnail_url ? (
                    <img
                      src={video.thumbnail_url}
                      alt=""
                      className="w-20 h-12 rounded-lg object-cover bg-slate-900 border border-slate-200 shrink-0 cursor-pointer"
                      onClick={() => openVideoDetail(video)}
                    />
                  ) : (
                    <div
                      onClick={() => openVideoDetail(video)}
                      className="w-20 h-12 rounded-lg bg-slate-900 text-indigo-400 flex items-center justify-center font-bold text-xs shrink-0 cursor-pointer"
                    >
                      <Play size={18} />
                    </div>
                  )}

                  <div className="min-w-0">
                    <button
                      onClick={() => openVideoDetail(video)}
                      className="font-semibold text-slate-900 hover:text-indigo-600 text-sm truncate text-left block max-w-md transition-colors cursor-pointer"
                    >
                      {video.title}
                    </button>
                    <div className="flex items-center gap-3 text-xs text-slate-500 mt-1 flex-wrap">
                      <button
                        onClick={() => copyToClipboard(video.video_id)}
                        className="font-mono text-[11px] text-slate-500 bg-slate-100 hover:bg-slate-200 px-1.5 py-0.5 rounded flex items-center gap-1 transition-colors cursor-pointer"
                        title="Click to copy Video GUID"
                      >
                        <span>{video.video_id.substring(0, 16)}...</span>
                        <Copy size={11} />
                      </button>
                      <span>Duration: {formatDuration(video.length_seconds)}</span>
                      <span>&bull;</span>
                      <span>{video.views || 0} views</span>
                      {video.created_at && (
                        <>
                          <span>&bull;</span>
                          <span>{formatDate(video.created_at)}</span>
                        </>
                      )}
                    </div>
                  </div>
                </div>

                {/* Middle: Linked Lesson & Processing Status */}
                <div className="flex items-center gap-3 shrink-0 flex-wrap">
                  {video.linked_lesson ? (
                    <div className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-indigo-50 border border-indigo-200 text-indigo-800 text-xs">
                      <Layers size={13} className="text-indigo-600 shrink-0" />
                      <div className="min-w-0">
                        <span className="font-semibold">Linked: </span>
                        <span className="truncate max-w-[140px] inline-block align-bottom font-medium">
                          {video.linked_lesson.lesson_title}
                        </span>
                      </div>
                      <button
                        onClick={() => setUnlinkingVideo(video)}
                        title="Unlink video from lesson"
                        className="text-slate-400 hover:text-rose-600 ml-1 cursor-pointer"
                      >
                        <Unlink size={13} />
                      </button>
                    </div>
                  ) : (
                    <Badge variant="warning" size="sm" className="gap-1">
                      <AlertCircle size={12} />
                      <span>Unlinked</span>
                    </Badge>
                  )}

                  {getStatusBadge(video.status)}
                </div>

                {/* Right: Actions */}
                <div className="flex items-center justify-end gap-1.5 shrink-0">
                  <button
                    onClick={() => openVideoDetail(video)}
                    className="p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-md transition-colors cursor-pointer"
                    title="Inspect Video Details"
                  >
                    <Info size={16} />
                  </button>

                  <button
                    onClick={() => openLinkModal(video)}
                    className="px-2.5 py-1.5 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 rounded-md text-xs font-semibold flex items-center gap-1.5 transition-colors cursor-pointer"
                  >
                    <Link2 size={13} />
                    <span>{video.linked_lesson ? 'Re-link' : 'Link Lesson'}</span>
                  </button>

                  <button
                    onClick={() => setDeletingVideo(video)}
                    className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-md transition-colors cursor-pointer"
                    title="Permanently Delete Video from Bunny"
                  >
                    <Trash2 size={16} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Pagination Footer */}
        {totalVideos > 15 && (
          <div className="px-6 py-3 border-t border-slate-100 bg-slate-50 flex items-center justify-between text-xs text-slate-600">
            <span>
              Showing {(page - 1) * 15 + 1} - {Math.min(page * 15, totalVideos)} of {totalVideos} videos
            </span>
            <div className="flex items-center gap-2">
              <Button
                variant="secondary"
                size="sm"
                disabled={page <= 1}
                onClick={() => setPage(page - 1)}
                leftIcon={<ChevronLeft size={14} />}
              >
                Previous
              </Button>
              <Button
                variant="secondary"
                size="sm"
                disabled={page * 15 >= totalVideos}
                onClick={() => setPage(page + 1)}
                rightIcon={<ChevronRight size={14} />}
              >
                Next
              </Button>
            </div>
          </div>
        )}
      </div>

      {/* ── 1. DIRECT TUS UPLOAD MODAL ────────────────────────────────────── */}
      <Modal
        isOpen={isUploadOpen}
        onClose={handleCancelUpload}
        title="Direct Video Upload to Bunny CDN"
        subtitle="Zero-proxy resumable chunked upload powered by tus-js-client"
        maxWidth="lg"
      >
        <form onSubmit={handleStartUpload} className="space-y-4">
          {uploadError && (
            <div className="p-3 bg-rose-50 border border-rose-200 text-rose-800 rounded-lg text-xs flex items-start gap-2">
              <AlertCircle size={15} className="text-rose-600 shrink-0 mt-0.5" />
              <div>
                <p className="font-bold">Upload Error</p>
                <p className="mt-0.5">{uploadError}</p>
              </div>
            </div>
          )}

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Select Video File (.mp4, .mov, .mkv, .webm) *
            </label>
            <input
              type="file"
              accept="video/*"
              disabled={uploadStage !== 'idle' && uploadStage !== 'error'}
              onChange={(e) => {
                const file = e.target.files?.[0] || null;
                setUploadFile(file);
                if (file && !videoTitle) {
                  setVideoTitle(file.name.replace(/\.[^/.]+$/, ''));
                }
              }}
              className="w-full text-sm text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-xs file:font-semibold file:bg-indigo-50 file:text-indigo-700 hover:file:bg-indigo-100"
              required
            />
            {uploadFile && (
              <p className="text-[11px] text-slate-400 mt-1">
                File size: {(uploadFile.size / (1024 * 1024)).toFixed(1)} MB
              </p>
            )}
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Video Title in Bunny Library
            </label>
            <input
              type="text"
              value={videoTitle}
              disabled={uploadStage !== 'idle' && uploadStage !== 'error'}
              onChange={(e) => setVideoTitle(e.target.value)}
              placeholder="e.g. Chapter 1: Introduction to Robotics Hardware"
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none disabled:bg-slate-100"
            />
          </div>

          {/* Real-time Progress Bar & Stage Status */}
          {uploadStage !== 'idle' && (
            <div className="space-y-2 pt-2 p-3 bg-slate-50 rounded-xl border border-slate-200">
              <div className="flex justify-between text-xs font-semibold text-slate-700">
                <span className="flex items-center gap-1.5">
                  {uploadStage === 'uploading' && <UploadCloud size={14} className="text-indigo-600 animate-bounce" />}
                  {uploadStage === 'processing' && <Clock size={14} className="text-amber-600 animate-spin" />}
                  {uploadStage === 'ready' && <CheckCircle2 size={14} className="text-emerald-600" />}
                  {uploadStatusText}
                </span>
                <span>{uploadProgress}%</span>
              </div>
              {totalBytes > 0 && uploadStage === 'uploading' && (
                <p className="text-[11px] text-slate-500 font-mono">
                  {(uploadedBytes / (1024 * 1024)).toFixed(1)} MB of {(totalBytes / (1024 * 1024)).toFixed(1)} MB
                </p>
              )}
              <div className="w-full bg-slate-200 rounded-full h-2.5 overflow-hidden">
                <div
                  className={`h-2.5 rounded-full transition-all duration-300 ease-out ${
                    uploadStage === 'ready'
                      ? 'bg-emerald-600'
                      : uploadStage === 'error'
                      ? 'bg-rose-600'
                      : 'bg-indigo-600'
                  }`}
                  style={{ width: `${uploadProgress}%` }}
                />
              </div>
            </div>
          )}

          <div className="flex justify-end gap-3 pt-4 border-t border-slate-100">
            <Button
              type="button"
              variant="secondary"
              onClick={handleCancelUpload}
            >
              {uploadStage === 'uploading' ? 'Cancel Upload' : 'Close'}
            </Button>
            {uploadStage === 'idle' || uploadStage === 'error' ? (
              <Button type="submit" disabled={!uploadFile} leftIcon={<UploadCloud size={16} />}>
                Start Direct Upload
              </Button>
            ) : (
              <Button type="button" disabled isLoading>
                Uploading to Bunny...
              </Button>
            )}
          </div>
        </form>
      </Modal>

      {/* ── 2. VIDEO DETAILS MODAL ────────────────────────────────────────── */}
      <Modal
        isOpen={!!selectedVideo}
        onClose={() => setSelectedVideo(null)}
        title={selectedVideo?.title || 'Video Details'}
        subtitle="Bunny CDN Stream Metadata & Lesson Association"
        maxWidth="lg"
      >
        {selectedVideo && (
          <div className="space-y-4 text-xs">
            {/* Thumbnail Preview Banner */}
            {selectedVideo.thumbnail_url ? (
              <div className="rounded-xl overflow-hidden bg-slate-900 border border-slate-200 max-h-48 flex items-center justify-center">
                <img src={selectedVideo.thumbnail_url} alt="" className="w-full h-48 object-cover" />
              </div>
            ) : (
              <div className="h-32 rounded-xl bg-slate-900 flex items-center justify-center text-indigo-400 font-bold">
                <Play size={32} />
              </div>
            )}

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 p-4 bg-slate-50 rounded-xl border border-slate-200">
              <div>
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Video GUID</span>
                <div className="flex items-center gap-1.5 mt-0.5">
                  <code className="font-mono text-slate-800 bg-white px-1.5 py-0.5 rounded border border-slate-200">
                    {selectedVideo.video_id}
                  </code>
                  <button
                    onClick={() => copyToClipboard(selectedVideo.video_id)}
                    className="text-slate-400 hover:text-slate-700 p-1 cursor-pointer"
                    title="Copy GUID"
                  >
                    <Copy size={13} />
                  </button>
                </div>
              </div>

              <div>
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Processing Status</span>
                <div className="mt-1">{getStatusBadge(selectedVideo.status)}</div>
              </div>

              <div>
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Stream Duration</span>
                <p className="font-semibold text-slate-800 mt-0.5">
                  {formatDuration(selectedVideo.length_seconds)} ({selectedVideo.length_seconds || 0} seconds)
                </p>
              </div>

              <div>
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Library Views</span>
                <p className="font-semibold text-slate-800 mt-0.5">{selectedVideo.views || 0} views</p>
              </div>

              <div>
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Transcoding Status</span>
                <p className="font-semibold text-slate-800 mt-0.5">
                  {selectedVideo.has_mp4 ? 'MP4 Direct Download Ready' : 'Adaptive HLS Streaming Only'}
                </p>
              </div>

              <div>
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Created Date</span>
                <p className="font-semibold text-slate-800 mt-0.5">
                  {selectedVideo.created_at ? formatDate(selectedVideo.created_at) : 'N/A'}
                </p>
              </div>
            </div>

            {/* Attached Lesson Info */}
            <div className="p-3.5 bg-indigo-50/50 rounded-xl border border-indigo-100 flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <Layers size={16} className="text-indigo-600 shrink-0" />
                <div>
                  <p className="font-bold text-slate-800">
                    {selectedVideo.linked_lesson ? `Linked to: ${selectedVideo.linked_lesson.lesson_title}` : 'Not linked to any lesson'}
                  </p>
                  <p className="text-slate-500 text-[11px]">
                    {selectedVideo.linked_lesson ? `Course ID: #${selectedVideo.linked_lesson.course_id} — Lesson ID: #${selectedVideo.linked_lesson.lesson_id}` : 'Attach to a curriculum lesson so students can stream it.'}
                  </p>
                </div>
              </div>

              {selectedVideo.linked_lesson ? (
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    setSelectedVideo(null);
                    setUnlinkingVideo(selectedVideo);
                  }}
                >
                  Unlink
                </Button>
              ) : (
                <Button
                  size="sm"
                  onClick={() => {
                    setSelectedVideo(null);
                    openLinkModal(selectedVideo);
                  }}
                >
                  Link Now
                </Button>
              )}
            </div>

            <div className="flex justify-end pt-2">
              <Button variant="secondary" onClick={() => setSelectedVideo(null)}>
                Close
              </Button>
            </div>
          </div>
        )}
      </Modal>

      {/* ── 3. LINK VIDEO TO LESSON MODAL ─────────────────────────────────── */}
      <Modal
        isOpen={!!linkingVideo}
        onClose={() => setLinkingVideo(null)}
        title="Link Video to Curriculum Lesson"
        subtitle={`Associate '${linkingVideo?.title}' with a database lesson`}
        maxWidth="md"
      >
        <form onSubmit={handleLinkSubmit} className="space-y-4">
          {linkError && (
            <div className="p-3 bg-rose-50 border border-rose-200 text-rose-700 rounded-lg text-xs flex items-center gap-2">
              <AlertCircle size={15} className="shrink-0" />
              <span>{linkError}</span>
            </div>
          )}

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">Target Course</label>
            <select
              value={selectedCourseId || ''}
              onChange={(e) => handleCourseChangeInModal(Number(e.target.value))}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:ring-2 focus:ring-indigo-500 focus:outline-none"
            >
              {courses.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.title}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">Target Lesson</label>
            {courseLessons.length === 0 ? (
              <p className="text-xs text-rose-600 p-2.5 bg-rose-50 rounded-lg">
                This course has no lessons yet. Please create a lesson in Curriculum first.
              </p>
            ) : (
              <select
                value={selectedLessonId || ''}
                onChange={(e) => handleLessonChangeInModal(Number(e.target.value))}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              >
                {courseLessons.map((l) => (
                  <option key={l.id} value={l.id}>
                    #{l.order_index} - {l.title} {l.video_stream_id ? '(Has Existing Video)' : '(Empty)'}
                  </option>
                ))}
              </select>
            )}
          </div>

          {/* Conflict Warning & Overwrite Toggle */}
          {existingLessonVideoId && existingLessonVideoId !== linkingVideo?.video_id && (
            <div className="p-3.5 bg-amber-50 border border-amber-200 rounded-xl space-y-2 text-xs">
              <div className="flex items-center gap-2 text-amber-800 font-bold">
                <AlertTriangle size={15} className="text-amber-600 shrink-0" />
                <span>Existing Video Conflict</span>
              </div>
              <p className="text-amber-700">
                This lesson already has video <code>{existingLessonVideoId}</code> attached.
              </p>
              <label className="flex items-center gap-2 cursor-pointer font-semibold text-amber-900 pt-1">
                <input
                  type="checkbox"
                  checked={overwriteConflict}
                  onChange={(e) => setOverwriteConflict(e.target.checked)}
                  className="w-4 h-4 text-indigo-600 rounded-sm border-slate-300 focus:ring-indigo-500"
                />
                <span>Overwrite existing video link</span>
              </label>
            </div>
          )}

          <div className="flex justify-end gap-3 pt-4 border-t border-slate-100">
            <Button
              type="button"
              variant="secondary"
              onClick={() => setLinkingVideo(null)}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              isLoading={linkSubmitting}
              disabled={!selectedLessonId || (Boolean(existingLessonVideoId && existingLessonVideoId !== linkingVideo?.video_id) && !overwriteConflict)}
            >
              Confirm Link
            </Button>
          </div>
        </form>
      </Modal>

      {/* ── 4. UNLINK CONFIRMATION MODAL ──────────────────────────────────── */}
      <Modal
        isOpen={!!unlinkingVideo}
        onClose={() => setUnlinkingVideo(null)}
        title="Unlink Video from Lesson"
        subtitle="Detach stream reference from student curriculum"
        maxWidth="md"
      >
        <div className="space-y-4 text-xs sm:text-sm text-slate-600">
          <p>
            Are you sure you want to unlink video <strong className="text-slate-900">"{unlinkingVideo?.title}"</strong> from its attached lesson?
          </p>
          <div className="p-3 bg-slate-50 rounded-lg border border-slate-200 text-xs text-slate-500">
            <span className="font-semibold text-slate-700">Note: </span>
            Unlinking removes the lesson association in the database but does NOT delete the Bunny video file.
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <Button variant="secondary" onClick={() => setUnlinkingVideo(null)}>
              Cancel
            </Button>
            <Button variant="danger" isLoading={actionSubmitting} onClick={handleUnlinkSubmit}>
              Unlink Video
            </Button>
          </div>
        </div>
      </Modal>

      {/* ── 5. DELETE VIDEO CONFIRMATION MODAL ─────────────────────────────── */}
      <Modal
        isOpen={!!deletingVideo}
        onClose={() => setDeletingVideo(null)}
        title="Permanently Delete Bunny Stream Video"
        subtitle="This action will permanently erase the video file from Bunny CDN"
        maxWidth="md"
      >
        <div className="space-y-4 text-xs sm:text-sm text-slate-600">
          <div className="p-3.5 bg-rose-50 border border-rose-200 rounded-xl text-rose-800 text-xs flex items-start gap-2.5">
            <AlertTriangle size={18} className="text-rose-600 shrink-0 mt-0.5" />
            <div>
              <p className="font-bold">Irreversible Action</p>
              <p className="mt-0.5">
                Deleting <strong>"{deletingVideo?.title}"</strong> (
                <code className="font-mono">{deletingVideo?.video_id}</code>
                ) will permanently erase all transcoded streaming resolutions from Bunny CDN.
              </p>
            </div>
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <Button variant="secondary" onClick={() => setDeletingVideo(null)}>
              Cancel
            </Button>
            <Button variant="danger" isLoading={actionSubmitting} onClick={handleDeleteSubmit}>
              Delete from Bunny
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
};
