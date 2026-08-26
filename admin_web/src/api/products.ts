import { apiClient } from './client';
import { Product } from '../types';

export interface GetProductsParams {
  product_type?: 'diy_kit' | 'electronics';
  category?: string;
  is_active?: boolean;
}

export async function fetchAdminProducts(params?: GetProductsParams): Promise<Product[]> {
  return apiClient<Product[]>('/api/admin/products', { params });
}

export async function fetchAdminProductDetail(productId: number): Promise<Product> {
  return apiClient<Product>(`/api/admin/products/${productId}`);
}

export async function createAdminProduct(data: Partial<Product>): Promise<Product> {
  return apiClient<Product>('/api/admin/products', {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

export async function updateAdminProduct(productId: number, data: Partial<Product>): Promise<Product> {
  return apiClient<Product>(`/api/admin/products/${productId}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  });
}

export async function toggleProductActive(productId: number, isActive: boolean): Promise<Product> {
  return apiClient<Product>(`/api/admin/products/${productId}`, {
    method: 'PUT',
    body: JSON.stringify({ is_active: isActive }),
  });
}

export async function deleteAdminProduct(productId: number): Promise<{ success: boolean; message: string }> {
  return apiClient<{ success: boolean; message: string }>(`/api/admin/products/${productId}`, {
    method: 'DELETE',
  });
}
