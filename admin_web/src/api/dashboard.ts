import { apiClient } from './client';
import { AdminStats } from '../types';

export async function fetchAdminStats(): Promise<AdminStats> {
  return apiClient<AdminStats>('/api/admin/stats');
}
