import { apiClient } from './client';
import { Lesson } from '../types';

export async function createAdminLesson(courseId: number, data: Partial<Lesson>): Promise<Lesson> {
  return apiClient<Lesson>(`/api/admin/courses/${courseId}/lessons`, {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

export async function updateAdminLesson(lessonId: number, data: Partial<Lesson>): Promise<Lesson> {
  return apiClient<Lesson>(`/api/admin/lessons/${lessonId}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  });
}

export async function deleteAdminLesson(
  lessonId: number
): Promise<{ success: boolean; message: string; course_id: number }> {
  return apiClient<{ success: boolean; message: string; course_id: number }>(
    `/api/admin/lessons/${lessonId}`,
    {
      method: 'DELETE',
    }
  );
}

export async function reorderAdminLessons(
  courseId: number,
  lessonIds: number[]
): Promise<{ success: boolean; message: string }> {
  return apiClient<{ success: boolean; message: string }>(
    `/api/admin/courses/${courseId}/lessons/reorder`,
    {
      method: 'POST',
      body: JSON.stringify({ lesson_ids: lessonIds }),
    }
  );
}
