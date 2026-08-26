import { apiClient } from './client';
import { CourseEntitlement, UserProfile, UserRole } from '../types';

export interface GetUsersParams {
  role?: UserRole | string;
  search?: string;
  limit?: number;
  offset?: number;
}

export interface UsersResponse {
  total: number;
  limit: number;
  offset: number;
  users: UserProfile[];
}

export async function fetchAdminUsers(params?: GetUsersParams): Promise<UsersResponse> {
  return apiClient<UsersResponse>('/api/admin/users', { params });
}

export async function updateUserRole(
  userId: number,
  role: UserRole
): Promise<{ success: boolean; user_id: number; email: string; role: UserRole }> {
  return apiClient<{ success: boolean; user_id: number; email: string; role: UserRole }>(
    `/api/admin/users/${userId}/role`,
    {
      method: 'PATCH',
      body: JSON.stringify({ role }),
    }
  );
}

export async function fetchUserEntitlements(userId: number): Promise<CourseEntitlement[]> {
  return apiClient<CourseEntitlement[]>(`/api/admin/users/${userId}/entitlements`);
}

export async function grantCourseEntitlement(
  userId: number,
  courseId: number,
  orderId?: string
): Promise<{ success: boolean; message: string; entitlement_id: number; status: string }> {
  return apiClient<{ success: boolean; message: string; entitlement_id: number; status: string }>(
    `/api/admin/users/${userId}/entitlements`,
    {
      method: 'POST',
      body: JSON.stringify({ course_id: courseId, order_id: orderId }),
    }
  );
}

export async function revokeCourseEntitlement(
  userId: number,
  courseId: number
): Promise<{ success: boolean; message: string; status: string }> {
  return apiClient<{ success: boolean; message: string; status: string }>(
    `/api/admin/users/${userId}/entitlements/${courseId}`,
    {
      method: 'DELETE',
    }
  );
}
