import React, { useEffect, useState } from 'react';
import { useSearchParams, Link } from 'react-router-dom';
import { fetchAdminCourses, fetchAdminCourseDetail, toggleCoursePublish } from '../api/courses';
import {
  createAdminLesson,
  updateAdminLesson,
  deleteAdminLesson,
  reorderAdminLessons,
} from '../api/lessons';
import { Course, Lesson } from '../types';
import { formatDuration } from '../utils/format';
import { useToast } from '../context/ToastContext';
import {
  BookOpen,
  Plus,
  Edit2,
  Trash2,
  Video,
  ArrowUp,
  ArrowDown,
  FileText,
  Cpu,
  Sparkles,
  AlertCircle,
  RefreshCw,
  ExternalLink,
  CheckCircle2,
  Lock,
  Clock,
} from 'lucide-react';
import { Badge } from '../components/Badge';
import { Modal } from '../components/Modal';
import { Button } from '../components/Button';
import { PageHeader } from '../components/PageHeader';
import { EmptyState } from '../components/EmptyState';
import { TableSkeleton } from '../components/LoadingSkeleton';

export const CurriculumPage: React.FC = () => {
  const toast = useToast();
  const [searchParams, setSearchParams] = useSearchParams();
  const [courses, setCourses] = useState<Course[]>([]);
  const [selectedCourseId, setSelectedCourseId] = useState<number | null>(null);
  const [courseDetail, setCourseDetail] = useState<Course | null>(null);
  const [lessonsLoading, setLessonsLoading] = useState(false);
  const [reordering, setReordering] = useState(false);
  const [togglingPublish, setTogglingPublish] = useState(false);

  // Lesson Modals
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [editingLesson, setEditingLesson] = useState<Lesson | null>(null);
  const [deletingLesson, setDeletingLesson] = useState<Lesson | null>(null);
  const [formSubmitting, setFormSubmitting] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  // Lesson Form Data
  const [formData, setFormData] = useState<Partial<Lesson>>({
    title: '',
    description: '',
    video_stream_id: '',
    duration: 300,
    is_free_preview: false,
    notes_pdf: '',
    circuit_diagram: '',
  });

  // 1. Fetch courses list
  useEffect(() => {
    const loadCourses = async () => {
      try {
        const data = await fetchAdminCourses();
        setCourses(data);

        const paramId = searchParams.get('courseId');
        if (paramId && data.some((c) => c.id === parseInt(paramId))) {
          setSelectedCourseId(parseInt(paramId));
        } else if (data.length > 0) {
          setSelectedCourseId(data[0].id);
        }
      } catch (err: any) {
        toast.error('Failed to load courses', err?.message);
      }
    };
    loadCourses();
  }, []);

  // 2. Fetch selected course details with lessons
  const loadLessons = async (courseId: number) => {
    setLessonsLoading(true);
    try {
      const detail = await fetchAdminCourseDetail(courseId);
      setCourseDetail(detail);
    } catch (err: any) {
      toast.error('Failed to load course lessons', err?.message);
    } finally {
      setLessonsLoading(false);
    }
  };

  useEffect(() => {
    if (selectedCourseId) {
      setSearchParams({ courseId: String(selectedCourseId) });
      loadLessons(selectedCourseId);
    }
  }, [selectedCourseId]);

  const handleToggleCoursePublish = async () => {
    if (!courseDetail) return;
    const nextState = !courseDetail.is_published;
    setTogglingPublish(true);
    try {
      await toggleCoursePublish(courseDetail.id, nextState);
      setCourseDetail({ ...courseDetail, is_published: nextState });
      setCourses((prev) =>
        prev.map((c) => (c.id === courseDetail.id ? { ...c, is_published: nextState } : c))
      );
      toast.success(
        nextState ? 'Course Published' : 'Course Set to Draft',
        `"${courseDetail.title}" is now ${nextState ? 'publicly visible' : 'hidden'}.`
      );
    } catch (err: any) {
      toast.error('Failed to update publish state', err?.message);
    } finally {
      setTogglingPublish(false);
    }
  };

  const openAddLessonModal = () => {
    const nextOrder = (courseDetail?.lessons?.length || 0) + 1;
    setFormData({
      title: `Lesson ${nextOrder}: `,
      description: '',
      video_stream_id: '',
      duration: 300,
      order_index: nextOrder,
      is_free_preview: nextOrder <= 3,
      notes_pdf: '',
      circuit_diagram: '',
    });
    setFormError(null);
    setIsAddOpen(true);
  };

  const openEditLessonModal = (lesson: Lesson) => {
    setEditingLesson(lesson);
    setFormData({
      title: lesson.title,
      description: lesson.description || '',
      video_stream_id: lesson.video_stream_id || '',
      duration: lesson.duration || 0,
      order_index: lesson.order_index,
      is_free_preview: lesson.is_free_preview,
      notes_pdf: lesson.notes_pdf || '',
      circuit_diagram: lesson.circuit_diagram || '',
    });
    setFormError(null);
  };

  const handleSaveLesson = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedCourseId) return;
    if (!formData.title?.trim()) {
      setFormError('Lesson title is required.');
      return;
    }

    setFormSubmitting(true);
    setFormError(null);
    try {
      if (editingLesson) {
        await updateAdminLesson(editingLesson.id, formData);
        toast.success('Lesson Updated', `"${formData.title}" saved successfully.`);
      } else {
        await createAdminLesson(selectedCourseId, formData);
        toast.success('Lesson Added', `"${formData.title}" added to curriculum.`);
      }
      setIsAddOpen(false);
      setEditingLesson(null);
      await loadLessons(selectedCourseId);
    } catch (err: any) {
      setFormError(err?.message || 'Failed to save lesson');
      toast.error('Save Failed', err?.message);
    } finally {
      setFormSubmitting(false);
    }
  };

  const handleDeleteLesson = async () => {
    if (!deletingLesson || !selectedCourseId) return;
    setFormSubmitting(true);
    try {
      await deleteAdminLesson(deletingLesson.id);
      toast.success('Lesson Deleted', `"${deletingLesson.title}" removed permanently.`);
      setDeletingLesson(null);
      await loadLessons(selectedCourseId);
    } catch (err: any) {
      toast.error('Deletion Failed', err?.message);
    } finally {
      setFormSubmitting(false);
    }
  };

  const handleMoveLesson = async (index: number, direction: 'up' | 'down') => {
    if (!courseDetail?.lessons || !selectedCourseId || reordering) return;
    const lessons = [...courseDetail.lessons];
    const targetIndex = direction === 'up' ? index - 1 : index + 1;

    if (targetIndex < 0 || targetIndex >= lessons.length) return;

    const temp = lessons[index];
    lessons[index] = lessons[targetIndex];
    lessons[targetIndex] = temp;

    const newIds = lessons.map((l) => l.id);
    setReordering(true);
    try {
      await reorderAdminLessons(selectedCourseId, newIds);
      toast.success('Curriculum Reordered', 'Chapter sequence saved.');
      await loadLessons(selectedCourseId);
    } catch (err: any) {
      toast.error('Reorder Failed', err?.message);
    } finally {
      setReordering(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <PageHeader
        title="Curriculum Studio"
        subtitle="Manage lesson sequencing, attach video streams, notes PDFs, and circuit diagrams"
        breadcrumbs={[{ label: 'Admin', href: '/' }, { label: 'Courses', href: '/courses' }, { label: 'Curriculum' }]}
        action={
          <div className="flex items-center gap-2.5">
            <button
              onClick={() => selectedCourseId && loadLessons(selectedCourseId)}
              className="p-2 bg-white hover:bg-slate-50 border border-slate-200 rounded-lg text-slate-600 hover:text-slate-900 transition-colors shadow-2xs cursor-pointer"
              title="Refresh Curriculum"
            >
              <RefreshCw size={15} />
            </button>
            <Button
              onClick={openAddLessonModal}
              disabled={!selectedCourseId}
              leftIcon={<Plus size={16} />}
            >
              Add Lesson
            </Button>
          </div>
        }
      />

      {/* Course Selection & Overview Bar */}
      <div className="bg-white p-4 sm:p-5 rounded-xl border border-slate-200 shadow-2xs space-y-4">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          {/* Course Selector Dropdown */}
          <div className="flex items-center gap-3 w-full md:w-auto">
            <div className="w-10 h-10 rounded-xl bg-indigo-50 text-indigo-700 flex items-center justify-center font-bold text-sm shrink-0 border border-indigo-100">
              <BookOpen size={18} />
            </div>
            <div className="min-w-0 flex-1 md:flex-initial">
              <label className="text-[11px] font-bold uppercase text-slate-400 tracking-wider">
                Select Active Course
              </label>
              <select
                value={selectedCourseId || ''}
                onChange={(e) => setSelectedCourseId(Number(e.target.value))}
                className="mt-0.5 block w-full px-3 py-1.5 border border-slate-300 rounded-lg text-sm font-semibold text-slate-900 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              >
                {courses.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.title} ({c.lessons_count || 0} lessons) — {c.is_published ? 'Published' : 'Draft'}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Course Metadata Summary & Quick Actions */}
          {courseDetail && (
            <div className="flex items-center gap-2.5 flex-wrap">
              <button
                onClick={handleToggleCoursePublish}
                disabled={togglingPublish}
                className="px-3 py-1.5 rounded-lg border border-slate-200 bg-slate-50 hover:bg-slate-100 text-xs font-semibold text-slate-700 flex items-center gap-1.5 transition-colors cursor-pointer"
                title="Toggle course visibility in mobile app"
              >
                {courseDetail.is_published ? (
                  <>
                    <CheckCircle2 size={13} className="text-emerald-600" />
                    <span>Status: Published</span>
                  </>
                ) : (
                  <>
                    <Clock size={13} className="text-amber-600" />
                    <span>Status: Draft</span>
                  </>
                )}
              </button>

              <Link
                to="/videos"
                className="px-3 py-1.5 rounded-lg border border-indigo-200 bg-indigo-50 hover:bg-indigo-100 text-xs font-semibold text-indigo-700 flex items-center gap-1.5 transition-colors"
                title="Go to Bunny Video Hub"
              >
                <Video size={13} />
                <span>Bunny Video Hub</span>
                <ExternalLink size={11} />
              </Link>
            </div>
          )}
        </div>
      </div>

      {/* Lessons List Container */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-2xs overflow-hidden">
        <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between flex-wrap gap-2">
          <div>
            <h3 className="font-bold text-slate-800 text-sm">
              Syllabus Structure ({courseDetail?.lessons?.length || 0} Lessons)
            </h3>
            <p className="text-xs text-slate-400 mt-0.5">
              Drag-free deterministic reordering with live database sync
            </p>
          </div>
          <Badge variant="purple" size="sm" className="gap-1">
            <Sparkles size={11} />
            <span>Lessons 1-3 Default Free Previews</span>
          </Badge>
        </div>

        {lessonsLoading ? (
          <TableSkeleton rows={4} />
        ) : !courseDetail?.lessons || courseDetail.lessons.length === 0 ? (
          <EmptyState
            icon={BookOpen}
            title="No lessons created yet"
            description="Start creating the syllabus for this course by adding lessons and attaching video streams."
            actionLabel="+ Add First Lesson"
            onAction={openAddLessonModal}
          />
        ) : (
          <div className="divide-y divide-slate-100">
            {courseDetail.lessons
              .sort((a, b) => a.order_index - b.order_index)
              .map((lesson, idx) => (
                <div
                  key={lesson.id}
                  className="p-4 sm:px-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4 hover:bg-slate-50/75 transition-colors"
                >
                  {/* Left: Reorder arrows & Lesson Info */}
                  <div className="flex items-center gap-4 min-w-0">
                    <div className="flex flex-col gap-1 text-slate-400 shrink-0">
                      <button
                        onClick={() => handleMoveLesson(idx, 'up')}
                        disabled={idx === 0 || reordering}
                        className="p-1 hover:text-indigo-600 hover:bg-indigo-50 rounded disabled:opacity-20 transition-colors cursor-pointer"
                        title="Move Lesson Up"
                      >
                        <ArrowUp size={14} />
                      </button>
                      <button
                        onClick={() => handleMoveLesson(idx, 'down')}
                        disabled={idx === (courseDetail.lessons?.length || 0) - 1 || reordering}
                        className="p-1 hover:text-indigo-600 hover:bg-indigo-50 rounded disabled:opacity-20 transition-colors cursor-pointer"
                        title="Move Lesson Down"
                      >
                        <ArrowDown size={14} />
                      </button>
                    </div>

                    <div className="w-8 h-8 rounded-lg bg-indigo-50 text-indigo-700 font-bold text-xs flex items-center justify-center shrink-0 border border-indigo-100">
                      #{lesson.order_index}
                    </div>

                    <div className="min-w-0">
                      <div className="flex items-center gap-2 flex-wrap">
                        <h4 className="font-semibold text-slate-900 text-sm">{lesson.title}</h4>
                        {lesson.is_free_preview ? (
                          <Badge variant="purple" size="sm" className="gap-1 text-[10px]">
                            <Sparkles size={11} />
                            <span>Free Preview</span>
                          </Badge>
                        ) : (
                          <Badge variant="default" size="sm" className="gap-1 text-[10px]">
                            <Lock size={10} />
                            <span>Enrolled Only</span>
                          </Badge>
                        )}
                      </div>
                      <p className="text-xs text-slate-500 mt-0.5 line-clamp-1">
                        {lesson.description || 'No detailed syllabus description provided.'}
                      </p>
                    </div>
                  </div>

                  {/* Middle: Video Link Indicator & Learning Assets */}
                  <div className="flex items-center gap-2.5 shrink-0 text-xs flex-wrap">
                    {/* Video Status Indicator */}
                    {lesson.video_stream_id ? (
                      <Link
                        to="/videos"
                        className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-md bg-sky-50 hover:bg-sky-100 border border-sky-200 text-sky-800 text-[11px] font-mono transition-colors"
                        title={`Bunny Video GUID: ${lesson.video_stream_id} — Click to view in Video Hub`}
                      >
                        <Video size={12} className="text-sky-600" />
                        <span className="truncate max-w-[100px]">{lesson.video_stream_id}</span>
                      </Link>
                    ) : (
                      <Link
                        to="/videos"
                        className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-amber-50 hover:bg-amber-100 border border-amber-200 text-amber-800 text-xs font-medium transition-colors"
                        title="No video attached — Click to open Video Hub"
                      >
                        <AlertCircle size={12} className="text-amber-600" />
                        <span>+ Attach Video</span>
                      </Link>
                    )}

                    <span className="text-slate-500 font-medium font-mono text-xs">
                      {formatDuration(lesson.duration)}
                    </span>

                    {/* PDF Attachment */}
                    {lesson.notes_pdf ? (
                      <a
                        href={lesson.notes_pdf}
                        target="_blank"
                        rel="noreferrer"
                        className="p-1 text-indigo-600 bg-indigo-50 hover:bg-indigo-100 rounded transition-colors"
                        title="Notes PDF Attached"
                      >
                        <FileText size={14} />
                      </a>
                    ) : null}

                    {/* Circuit Diagram Attachment */}
                    {lesson.circuit_diagram ? (
                      <a
                        href={lesson.circuit_diagram}
                        target="_blank"
                        rel="noreferrer"
                        className="p-1 text-emerald-600 bg-emerald-50 hover:bg-emerald-100 rounded transition-colors"
                        title="Circuit Diagram Attached"
                      >
                        <Cpu size={14} />
                      </a>
                    ) : null}
                  </div>

                  {/* Right: Actions */}
                  <div className="flex items-center justify-end gap-1.5 shrink-0">
                    <button
                      onClick={() => openEditLessonModal(lesson)}
                      className="p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-md transition-colors cursor-pointer"
                      title="Edit Lesson"
                    >
                      <Edit2 size={16} />
                    </button>
                    <button
                      onClick={() => setDeletingLesson(lesson)}
                      className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-md transition-colors cursor-pointer"
                      title="Delete Lesson"
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>
                </div>
              ))}
          </div>
        )}
      </div>

      {/* ADD / EDIT LESSON MODAL */}
      <Modal
        isOpen={isAddOpen || !!editingLesson}
        onClose={() => {
          setIsAddOpen(false);
          setEditingLesson(null);
        }}
        title={editingLesson ? `Edit Lesson: ${editingLesson.title}` : 'Add Lesson to Syllabus'}
        subtitle="Configure lesson title, duration, video stream reference, and learning resources"
        maxWidth="lg"
      >
        <form onSubmit={handleSaveLesson} className="space-y-4">
          {formError && (
            <div className="p-3 bg-rose-50 border border-rose-200 text-rose-700 rounded-lg text-xs flex items-center gap-2">
              <AlertCircle size={14} className="shrink-0" />
              <span>{formError}</span>
            </div>
          )}

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Lesson Title *
            </label>
            <input
              type="text"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              placeholder="e.g. Lesson 1: Introduction to Microcontrollers"
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              required
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">Description</label>
            <textarea
              rows={2}
              value={formData.description || ''}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              placeholder="What students will build or master in this session"
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Bunny Video Stream GUID
              </label>
              <input
                type="text"
                value={formData.video_stream_id || ''}
                onChange={(e) => setFormData({ ...formData, video_stream_id: e.target.value })}
                placeholder="e.g. 8421c97a-6b83-4a11-..."
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm font-mono text-xs focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              />
              <p className="text-[11px] text-slate-400 mt-1">
                Attach Bunny video GUID or link via Videos page
              </p>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Duration (Seconds)
              </label>
              <input
                type="number"
                min="0"
                value={formData.duration || 0}
                onChange={(e) =>
                  setFormData({ ...formData, duration: parseInt(e.target.value) || 0 })
                }
                placeholder="300"
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              />
              <p className="text-[11px] text-slate-400 mt-1">
                Formatted: {formatDuration(formData.duration)}
              </p>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Notes PDF Document URL
              </label>
              <input
                type="url"
                value={formData.notes_pdf || ''}
                onChange={(e) => setFormData({ ...formData, notes_pdf: e.target.value })}
                placeholder="https://..."
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Circuit Diagram Image URL
              </label>
              <input
                type="url"
                value={formData.circuit_diagram || ''}
                onChange={(e) => setFormData({ ...formData, circuit_diagram: e.target.value })}
                placeholder="https://..."
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              />
            </div>
          </div>

          <div className="pt-2 border-t border-slate-100">
            <label className="flex items-center gap-2 cursor-pointer text-sm font-medium text-slate-700">
              <input
                type="checkbox"
                checked={formData.is_free_preview}
                onChange={(e) => setFormData({ ...formData, is_free_preview: e.target.checked })}
                className="w-4 h-4 text-indigo-600 rounded-sm border-slate-300 focus:ring-indigo-500"
              />
              <span>Enable Free Preview (Students can view without buying course)</span>
            </label>
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-slate-100">
            <Button
              type="button"
              variant="secondary"
              onClick={() => {
                setIsAddOpen(false);
                setEditingLesson(null);
              }}
            >
              Cancel
            </Button>
            <Button type="submit" isLoading={formSubmitting}>
              {editingLesson ? 'Save Changes' : 'Add Lesson'}
            </Button>
          </div>
        </form>
      </Modal>

      {/* DELETE LESSON CONFIRMATION MODAL */}
      <Modal
        isOpen={!!deletingLesson}
        onClose={() => setDeletingLesson(null)}
        title="Confirm Lesson Deletion"
        subtitle="This action cannot be undone"
        maxWidth="md"
      >
        <div className="space-y-4">
          <p className="text-sm text-slate-600">
            Are you sure you want to permanently delete lesson{' '}
            <strong className="text-slate-900">"{deletingLesson?.title}"</strong>?
          </p>
          <div className="flex justify-end gap-3 pt-2">
            <Button type="button" variant="secondary" onClick={() => setDeletingLesson(null)}>
              Cancel
            </Button>
            <Button
              type="button"
              variant="danger"
              isLoading={formSubmitting}
              onClick={handleDeleteLesson}
            >
              Delete Permanently
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
};
