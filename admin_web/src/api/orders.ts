import { apiClient } from './client';
import { Order, OrderStatus } from '../types';

export interface GetOrdersParams {
  order_status?: OrderStatus | string;
  payment_status?: string;
  search?: string;
  limit?: number;
  offset?: number;
}

export interface OrdersResponse {
  total: number;
  limit: number;
  offset: number;
  orders: Order[];
}

export async function fetchAdminOrders(params?: GetOrdersParams): Promise<OrdersResponse> {
  return apiClient<OrdersResponse>('/api/admin/orders', { params });
}

export async function fetchAdminOrderDetail(orderId: string): Promise<Order> {
  return apiClient<Order>(`/api/admin/orders/${orderId}`);
}

export async function updateAdminOrderStatus(
  orderId: string,
  newStatus: OrderStatus,
  trackingNumber?: string
): Promise<{ success: boolean; order_id: string; order_status: OrderStatus; payment_status: string; tracking_number?: string }> {
  const payload: Record<string, any> = { order_status: newStatus };
  if (trackingNumber && trackingNumber.trim()) {
    payload.tracking_number = trackingNumber.trim();
  }

  return apiClient<{ success: boolean; order_id: string; order_status: OrderStatus; payment_status: string; tracking_number?: string }>(
    `/api/admin/orders/${orderId}/status`,
    {
      method: 'PATCH',
      body: JSON.stringify(payload),
    }
  );
}
