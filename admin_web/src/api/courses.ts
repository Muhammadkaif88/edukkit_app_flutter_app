import { apiClient } from './client';
import { Course } from '../types';

export interface GetCoursesParams {
  category?: string;
  status_filter?: 'published' | 'draft';
}

export async function fetchAdminCourses(params?: GetCoursesParams): Promise<Course[]> {
  return apiClient<Course[]>('/api/admin/courses', { params });
}

export async function fetchAdminCourseDetail(courseId: number): Promise<Course> {
  return apiClient<Course>(`/api/admin/courses/${courseId}`);
}

export async function createAdminCourse(data: Partial<Course>): Promise<Course> {
  return apiClient<Course>('/api/admin/courses', {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

export async function updateAdminCourse(courseId: number, data: Partial<Course>): Promise<Course> {
  return apiClient<Course>(`/api/admin/courses/${courseId}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  });
}

export async function toggleCoursePublish(courseId: number, isPublished: boolean): Promise<Course> {
  return updateAdminCourse(courseId, { is_published: isPublished });
}

export async function deleteAdminCourse(courseId: number): Promise<{ success: boolean; message: string }> {
  return apiClient<{ success: boolean; message: string }>(`/api/admin/courses/${courseId}`, {
    method: 'DELETE',
  });
}
