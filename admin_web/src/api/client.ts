export const BASE_URL = import.meta.env.VITE_API_BASE_URL || 'https://edukkit-backend.onrender.com';

// In-memory token provider callback (set by AuthContext)
let tokenProvider: (() => Promise<string | null>) | null = null;
let activeDevToken: string | null = localStorage.getItem('edukkit_dev_token');

export function setTokenProvider(provider: () => Promise<string | null>) {
  tokenProvider = provider;
}

export function setDevToken(token: string | null) {
  activeDevToken = token;
  if (token) {
    localStorage.setItem('edukkit_dev_token', token);
  } else {
    localStorage.removeItem('edukkit_dev_token');
  }
}

export function getDevToken(): string | null {
  return activeDevToken;
}

export class ApiError extends Error {
  status: number;
  data: any;

  constructor(message: string, status: number, data?: any) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.data = data;
  }
}

interface RequestOptions extends RequestInit {
  params?: Record<string, any>;
}

export async function apiClient<T>(endpoint: string, options: RequestOptions = {}): Promise<T> {
  const { params, headers: customHeaders, ...restOptions } = options;

  let url = endpoint.startsWith('http') ? endpoint : `${BASE_URL}${endpoint}`;

  if (params) {
    const searchParams = new URLSearchParams();
    Object.entries(params).forEach(([key, val]) => {
      if (val !== undefined && val !== null && val !== '') {
        searchParams.append(key, String(val));
      }
    });
    const queryString = searchParams.toString();
    if (queryString) {
      url += (url.includes('?') ? '&' : '?') + queryString;
    }
  }

  // Retrieve Firebase ID token or dev token
  let token: string | null = null;
  if (activeDevToken) {
    token = activeDevToken;
  } else if (tokenProvider) {
    try {
      token = await tokenProvider();
    } catch (err) {
      console.warn('Failed to retrieve Firebase ID token:', err);
    }
  }

  const headers = new Headers(customHeaders);
  if (!headers.has('Content-Type') && !(restOptions.body instanceof FormData)) {
    headers.set('Content-Type', 'application/json');
  }

  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }

  const response = await fetch(url, {
    ...restOptions,
    headers,
  });

  if (!response.ok) {
    let errorData: any = null;
    let errorMessage = `Request failed with status ${response.status}`;
    try {
      errorData = await response.json();
      if (errorData?.detail) {
        errorMessage = typeof errorData.detail === 'string' ? errorData.detail : JSON.stringify(errorData.detail);
      } else if (errorData?.message) {
        errorMessage = errorData.message;
      }
    } catch {
      // response wasn't JSON
    }

    throw new ApiError(errorMessage, response.status, errorData);
  }

  // Handle empty 204 or non-json responses
  if (response.status === 204) {
    return {} as T;
  }

  const contentType = response.headers.get('content-type');
  if (contentType && contentType.includes('application/json')) {
    return (await response.json()) as T;
  }

  return (await response.text()) as unknown as T;
}
