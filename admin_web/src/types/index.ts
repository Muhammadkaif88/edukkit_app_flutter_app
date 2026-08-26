// Edukkit Admin Types

export type UserRole = 'student' | 'teacher' | 'admin' | 'staff';

export interface UserProfile {
  id: number;
  firebase_uid: string;
  name: string;
  email: string;
  phone?: string;
  role: UserRole;
  approval_status?: string;
  is_verified?: boolean;
  profile_image?: string;
  created_at?: string;
}

export interface AdminStats {
  users: {
    total_students: number;
    total_teachers: number;
    total_admins: number;
    total_users: number;
  };
  courses: {
    total_courses: number;
    published_courses: number;
    draft_courses: number;
    total_lessons: number;
  };
  store: {
    total_products: number;
    low_stock_count: number;
  };
  orders: {
    total_orders: number;
    today_orders?: number;
    paid_orders: number;
    pending_orders?: number;
    total_revenue: number;
    recent_orders?: Order[];
  };
  entitlements: {
    active_enrollments: number;
  };
}

export interface Lesson {
  id: number;
  course_id: number;
  title: string;
  description?: string;
  video_stream_id?: string;
  duration?: number;
  order_index: number;
  is_free_preview: boolean;
  notes_pdf?: string;
  circuit_diagram?: string;
}

export interface Course {
  id: number;
  title: string;
  description?: string;
  short_description?: string;
  thumbnail?: string;
  price: number;
  original_price?: number;
  category?: string;
  level: string;
  instructor: string;
  bunny_collection_id?: string;
  teacher_id?: number;
  is_published: boolean;
  is_free: boolean;
  lessons_count?: number;
  lessons?: Lesson[];
  created_at?: string;
  updated_at?: string;
}

export interface Product {
  id: number;
  name: string;
  description?: string;
  price: number;
  original_price?: number;
  stock: number;
  images: string[];
  category?: string;
  type: 'diy_kit' | 'electronics';
  is_active: boolean;
  linked_course_id?: number;
  created_at?: string;
  updated_at?: string;
}

export type OrderStatus =
  | 'PENDING_PAYMENT'
  | 'PAID'
  | 'PROCESSING'
  | 'PACKED'
  | 'SHIPPED'
  | 'DELIVERED'
  | 'CANCELLED';

export interface OrderItem {
  item_id: number;
  item_type: 'course' | 'diy_kit' | 'electronics';
  title?: string;
  price: number;
  quantity?: number;
}

export interface ShippingAddress {
  fullName?: string;
  addressLine1?: string;
  addressLine2?: string;
  city?: string;
  state?: string;
  pincode?: string;
  phone?: string;
}

export interface Order {
  id: string;
  user_id: string;
  customer_name?: string;
  customer_email?: string;
  customer_phone?: string;
  items: OrderItem[];
  items_total: number;
  delivery_fee: number;
  delivery_region?: string;
  delivery_fee_rule?: string;
  discount_amount: number;
  total_payable: number;
  currency: string;
  shipping_address?: ShippingAddress;
  payment_status: string;
  order_status: OrderStatus;
  payment_method?: string;
  cashfree_order_id?: string;
  cashfree_payment_id?: string;
  tracking_number?: string;
  razorpay_order_id?: string;
  razorpay_payment_id?: string;
  created_at?: string;
  updated_at?: string;
}

export interface CourseEntitlement {
  id: number;
  user_id: string;
  course_id: number;
  order_id?: string;
  status: 'ACTIVE' | 'REVOKED' | 'EXPIRED';
  granted_at?: string;
  expires_at?: string;
  revoked_at?: string;
}

export interface BunnyVideoUploadSession {
  video_id: string;
  upload_url: string;
  tus_headers: Record<string, string>;
  expires_at: number;
  instructions: string;
}

export interface BunnyVideo {
  video_id: string;
  title: string;
  status: 'created' | 'uploaded' | 'processing' | 'transcoding' | 'finished' | 'error' | 'upload_failed';
  length_seconds: number;
  views: number;
  has_mp4: boolean;
  collection_id?: string;
  created_at?: string;
  thumbnail_url?: string;
  preview_animation_url?: string;
  linked_lesson?: {
    lesson_id: number;
    lesson_title: string;
    course_id: number;
    is_free_preview?: boolean;
  } | null;
}

export interface BunnyVideoListResponse {
  total: number;
  page: number;
  per_page: number;
  videos: BunnyVideo[];
}

export interface PaginatedResponse<T = any> {
  total: number;
  limit: number;
  offset: number;
  items: T[];
}
