import * as tus from 'tus-js-client';
import { apiClient } from './client';
import { BunnyVideo, BunnyVideoListResponse, BunnyVideoUploadSession } from '../types';

export interface CreateUploadSessionParams {
  title: string;
  collection_id?: string;
}

export interface ListVideosParams {
  page?: number;
  per_page?: number;
  collection_id?: string;
  search?: string;
}

// 1. Create short-lived upload session via backend
export async function createUploadSession(
  params: CreateUploadSessionParams
): Promise<BunnyVideoUploadSession> {
  return apiClient<BunnyVideoUploadSession>('/api/admin/videos/upload-session', {
    method: 'POST',
    body: JSON.stringify(params),
  });
}

// 2. Poll video status until processed
export async function getVideoStatus(videoId: string): Promise<BunnyVideo> {
  return apiClient<BunnyVideo>(`/api/admin/videos/${videoId}/status`);
}

// 3. Get full video details
export async function getVideoDetail(videoId: string): Promise<BunnyVideo> {
  return apiClient<BunnyVideo>(`/api/admin/videos/${videoId}`);
}

// 4. List videos from Bunny library
export async function listLibraryVideos(params?: ListVideosParams): Promise<BunnyVideoListResponse> {
  return apiClient<BunnyVideoListResponse>('/api/admin/videos/', { params });
}

// 5. Link video to lesson
export async function linkVideoToLesson(
  videoId: string,
  lessonId: number,
  overwrite: boolean = false
): Promise<{ success: boolean; message: string; previous_video_id?: string }> {
  return apiClient<{ success: boolean; message: string; previous_video_id?: string }>(
    `/api/admin/videos/${videoId}/link-lesson`,
    {
      method: 'PATCH',
      body: JSON.stringify({ lesson_id: lessonId, overwrite }),
    }
  );
}

// 6. Unlink video from lesson
export async function unlinkVideoFromLesson(
  videoId: string
): Promise<{ success: boolean; message: string; unlinked_lesson_id: number }> {
  return apiClient<{ success: boolean; message: string; unlinked_lesson_id: number }>(
    `/api/admin/videos/${videoId}/unlink-lesson`,
    {
      method: 'PATCH',
    }
  );
}

// 7. Delete video from Bunny
export async function deleteBunnyVideo(
  videoId: string,
  unlinkLesson: boolean = true
): Promise<{ success: boolean; message: string }> {
  return apiClient<{ success: boolean; message: string }>(
    `/api/admin/videos/${videoId}?unlink_lesson=${unlinkLesson}`,
    {
      method: 'DELETE',
    }
  );
}

// 8. TUS Direct Upload Service to Bunny CDN
export interface DirectUploadCallbacks {
  onProgress?: (bytesUploaded: number, bytesTotal: number, percentage: number) => void;
  onSuccess?: () => void;
  onError?: (error: Error) => void;
}

export function startBunnyDirectTusUpload(
  file: File,
  session: BunnyVideoUploadSession,
  callbacks: DirectUploadCallbacks = {}
): tus.Upload {
  const upload = new tus.Upload(file, {
    endpoint: session.upload_url,
    retryDelays: [0, 3000, 5000, 10000, 20000],
    headers: session.tus_headers,
    chunkSize: 5 * 1024 * 1024, // 5MB chunks
    metadata: {
      filename: file.name,
      filetype: file.type,
      title: file.name,
    },
    onError: (error) => {
      console.error('TUS upload error:', error);
      if (callbacks.onError) callbacks.onError(error);
    },
    onProgress: (bytesUploaded, bytesTotal) => {
      const percentage = Math.round((bytesUploaded / bytesTotal) * 100);
      if (callbacks.onProgress) callbacks.onProgress(bytesUploaded, bytesTotal, percentage);
    },
    onSuccess: () => {
      if (callbacks.onSuccess) callbacks.onSuccess();
    },
  });

  upload.start();
  return upload;
}
