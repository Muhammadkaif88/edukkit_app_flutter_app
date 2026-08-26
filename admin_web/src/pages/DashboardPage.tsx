import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { fetchAdminStats } from '../api/dashboard';
import { BASE_URL, ApiError } from '../api/client';
import { AdminStats } from '../types';
import { formatCurrency } from '../utils/format';
import {
  GraduationCap,
  ShoppingBag,
  TrendingUp,
  Package,
  Layers,
  ArrowUpRight,
  ShieldCheck,
  AlertTriangle,
  RefreshCw,
  Video,
  XCircle,
} from 'lucide-react';
import { Badge } from '../components/Badge';
import { PageHeader } from '../components/PageHeader';
import { CardSkeleton } from '../components/LoadingSkeleton';

export const DashboardPage: React.FC = () => {
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [statsError, setStatsError] = useState<{ status: number; message: string } | null>(null);

  const loadStats = async (attempt = 1) => {
    setLoading(true);
    setStatsError(null);
    try {
      const data = await fetchAdminStats();
      setStats(data);
    } catch (err) {
      console.error(`[Dashboard] Failed to load admin stats (attempt ${attempt}):`, err);
      const isNetworkError = !(err instanceof ApiError);
      // Auto-retry up to 3 times for transient network errors (Render free tier spin-up)
      if (isNetworkError && attempt < 3) {
        console.warn(`[Dashboard] Network error — retrying in 3s (attempt ${attempt}/3)...`);
        setTimeout(() => loadStats(attempt + 1), 3000);
        return;
      }
      if (err instanceof ApiError) {
        setStatsError({ status: err.status, message: err.message });
      } else {
        setStatsError({ status: 0, message: String(err) });
      }
      setStats(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadStats();
  }, []);

  return (
    <div className="space-y-6">
      {/* Top Header */}
      <PageHeader
        title="Dashboard Overview"
        subtitle="Real-time commerce telemetry, LMS metrics, and live fulfillment stats"
        breadcrumbs={[{ label: 'Admin', href: '/' }, { label: 'Overview' }]}
        action={
          <button
            onClick={() => loadStats()}
            className="px-3.5 py-2 bg-white hover:bg-slate-50 border border-slate-200 rounded-lg text-xs font-semibold text-slate-700 shadow-2xs flex items-center gap-2 transition-colors cursor-pointer"
          >
            <RefreshCw size={14} className="text-slate-500" />
            <span>Refresh Stats</span>
          </button>
        }
      />

      {/* API Error Banner */}
      {!loading && statsError && (
        <div className="flex items-start gap-3 p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-800">
          <XCircle size={18} className="shrink-0 mt-0.5 text-rose-500" />
          <div className="flex-1 min-w-0">
            <p className="text-sm font-bold">
              {statsError.status === 401
                ? 'Authentication Required — Sign in with a real Firebase account to view live stats.'
                : statsError.status === 403
                ? 'Access Denied — Your account does not have administrator privileges on the backend.'
                : statsError.status === 0
                ? 'Network Error — Could not reach the backend. The Render free-tier service may be waking up (can take ~50s). Retrying automatically…'
                : `Backend Error (HTTP ${statsError.status}) — Stats could not be loaded.`}
            </p>
            <p className="text-xs mt-1 font-mono text-rose-600 break-all">{statsError.message}</p>
            <div className="flex items-center gap-3 mt-2">
              <p className="text-xs text-rose-500">
                Target: <span className="font-mono">{BASE_URL}/api/admin/stats</span>
              </p>
              <button
                onClick={() => loadStats()}
                className="text-xs font-bold text-rose-700 hover:text-rose-900 underline flex items-center gap-1"
              >
                <RefreshCw size={11} /> Retry Now
              </button>
            </div>
          </div>
        </div>
      )}

      {/* 5 Primary Order & Platform KPI Cards */}
      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
          <CardSkeleton />
          <CardSkeleton />
          <CardSkeleton />
          <CardSkeleton />
          <CardSkeleton />
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
          {/* Total Revenue */}
          <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-2xs hover:shadow-sm transition-shadow">
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-bold uppercase text-slate-500 tracking-wider">
                Total Revenue
              </span>
              <div className="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center">
                <TrendingUp size={18} />
              </div>
            </div>
            <div className="mt-3">
              <h3 className="text-2xl font-black text-slate-900 tracking-tight">
                {formatCurrency(stats?.orders?.total_revenue || 0)}
              </h3>
              <p className="text-xs text-slate-500 mt-1 flex items-center gap-1.5">
                <span className="font-semibold text-emerald-600">
                  {stats?.orders?.paid_orders || 0}
                </span>{' '}
                paid orders
              </p>
            </div>
          </div>

          {/* Total Orders */}
          <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-2xs hover:shadow-sm transition-shadow">
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-bold uppercase text-slate-500 tracking-wider">
                Total Orders
              </span>
              <div className="w-8 h-8 rounded-lg bg-indigo-50 text-indigo-600 flex items-center justify-center">
                <ShoppingBag size={18} />
              </div>
            </div>
            <div className="mt-3">
              <h3 className="text-2xl font-black text-slate-900 tracking-tight">
                {stats?.orders?.total_orders || 0}
              </h3>
              <p className="text-xs text-slate-500 mt-1 flex items-center gap-1.5">
                <span>Lifetime orders</span>
              </p>
            </div>
          </div>

          {/* Today's Orders */}
          <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-2xs hover:shadow-sm transition-shadow">
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-bold uppercase text-slate-500 tracking-wider">
                Today's Orders
              </span>
              <div className="w-8 h-8 rounded-lg bg-amber-50 text-amber-600 flex items-center justify-center">
                <Package size={18} />
              </div>
            </div>
            <div className="mt-3">
              <h3 className="text-2xl font-black text-slate-900 tracking-tight">
                {stats?.orders?.today_orders || 0}
              </h3>
              <p className="text-xs text-slate-500 mt-1 flex items-center gap-1.5">
                <span className="font-semibold text-amber-600">Placed today</span>
              </p>
            </div>
          </div>

          {/* Paid Orders */}
          <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-2xs hover:shadow-sm transition-shadow">
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-bold uppercase text-slate-500 tracking-wider">
                Paid Orders
              </span>
              <div className="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center">
                <ShieldCheck size={18} />
              </div>
            </div>
            <div className="mt-3">
              <h3 className="text-2xl font-black text-slate-900 tracking-tight">
                {stats?.orders?.paid_orders || 0}
              </h3>
              <p className="text-xs text-slate-500 mt-1 flex items-center gap-1.5">
                <span className="text-emerald-600 font-semibold">Payment verified</span>
              </p>
            </div>
          </div>

          {/* Pending Orders */}
          <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-2xs hover:shadow-sm transition-shadow">
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-bold uppercase text-slate-500 tracking-wider">
                Pending Orders
              </span>
              <div className="w-8 h-8 rounded-lg bg-rose-50 text-rose-600 flex items-center justify-center">
                <AlertTriangle size={18} />
              </div>
            </div>
            <div className="mt-3">
              <h3 className="text-2xl font-black text-slate-900 tracking-tight">
                {stats?.orders?.pending_orders || 0}
              </h3>
              <p className="text-xs text-slate-500 mt-1 flex items-center gap-1.5">
                <span className="text-rose-600 font-semibold">Awaiting fulfillment</span>
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Recent Orders Section */}
      <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-2xs">
        <div className="flex items-center justify-between pb-4 border-b border-slate-100">
          <div>
            <h3 className="font-bold text-slate-900 text-base">Recent Orders</h3>
            <p className="text-xs text-slate-500 mt-0.5">
              Live transaction stream from customer checkout & payment gateway
            </p>
          </div>
          <Link
            to="/orders"
            className="px-3 py-1.5 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 rounded-lg text-xs font-bold transition-colors flex items-center gap-1.5"
          >
            <span>Manage All Orders</span>
            <ArrowUpRight size={14} />
          </Link>
        </div>

        <div className="mt-4 overflow-x-auto">
          {stats?.orders?.recent_orders && stats.orders.recent_orders.length > 0 ? (
            <table className="w-full text-left text-xs text-slate-600">
              <thead className="text-[11px] uppercase bg-slate-50 text-slate-500 font-semibold border-b border-slate-200">
                <tr>
                  <th className="py-2.5 px-3">Order ID</th>
                  <th className="py-2.5 px-3">Customer</th>
                  <th className="py-2.5 px-3">Items</th>
                  <th className="py-2.5 px-3">Total</th>
                  <th className="py-2.5 px-3">Payment</th>
                  <th className="py-2.5 px-3">Lifecycle Status</th>
                  <th className="py-2.5 px-3 text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {stats.orders.recent_orders.map((o) => (
                  <tr key={o.id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="py-3 px-3 font-mono font-bold text-slate-900">
                      {o.id}
                    </td>
                    <td className="py-3 px-3">
                      <div className="font-semibold text-slate-800">{o.customer_name || 'Customer'}</div>
                      <div className="text-[11px] text-slate-400">{o.customer_email || ''}</div>
                    </td>
                    <td className="py-3 px-3">
                      <span className="text-slate-700 font-medium">
                        {o.items && o.items.length > 0
                          ? `${o.items.length} item(s)`
                          : '1 kit'}
                      </span>
                    </td>
                    <td className="py-3 px-3 font-black text-slate-900">
                      {formatCurrency(o.total_payable || 0)}
                    </td>
                    <td className="py-3 px-3">
                      <Badge
                        variant={o.payment_status === 'PAYMENT_SUCCESS' ? 'success' : 'warning'}
                        size="sm"
                      >
                        {o.payment_status === 'PAYMENT_SUCCESS' ? 'PAID' : o.payment_status}
                      </Badge>
                    </td>
                    <td className="py-3 px-3">
                      <Badge
                        variant={
                          o.order_status === 'DELIVERED'
                            ? 'success'
                            : o.order_status === 'SHIPPED'
                            ? 'info'
                            : o.order_status === 'PROCESSING' || o.order_status === 'PACKED' || o.order_status === 'PAID'
                            ? 'warning'
                            : 'default'
                        }
                        size="sm"
                      >
                        {o.order_status}
                      </Badge>
                    </td>
                    <td className="py-3 px-3 text-right">
                      <Link
                        to="/orders"
                        className="text-indigo-600 hover:text-indigo-800 font-bold hover:underline"
                      >
                        Inspect &rarr;
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <div className="py-8 text-center text-slate-400 text-xs font-medium">
              No recent orders found.
            </div>
          )}
        </div>
      </div>

      {/* Grid: Quick Actions & Live Breakdown */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Quick Operations Actions */}
        <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-2xs flex flex-col justify-between">
          <div>
            <h3 className="font-bold text-slate-900 text-base">Quick Admin Shortcuts</h3>
            <p className="text-xs text-slate-500 mt-0.5">Direct access to core studio modules</p>

            <div className="mt-4 space-y-2">
              <Link
                to="/orders"
                className="flex items-center justify-between p-3 rounded-lg bg-slate-50 hover:bg-indigo-50/70 border border-slate-100 hover:border-indigo-100 transition-all text-xs font-semibold text-slate-700 hover:text-indigo-700"
              >
                <div className="flex items-center gap-3">
                  <div className="w-7 h-7 rounded-md bg-indigo-100 text-indigo-700 flex items-center justify-center">
                    <ShoppingBag size={14} />
                  </div>
                  <span>Store Orders & Fulfillment</span>
                </div>
                <ArrowUpRight size={14} className="text-slate-400" />
              </Link>

              <Link
                to="/videos"
                className="flex items-center justify-between p-3 rounded-lg bg-slate-50 hover:bg-indigo-50/70 border border-slate-100 hover:border-indigo-100 transition-all text-xs font-semibold text-slate-700 hover:text-indigo-700"
              >
                <div className="flex items-center gap-3">
                  <div className="w-7 h-7 rounded-md bg-indigo-100 text-indigo-700 flex items-center justify-center">
                    <Video size={14} />
                  </div>
                  <span>Upload Video to Bunny CDN</span>
                </div>
                <ArrowUpRight size={14} className="text-slate-400" />
              </Link>

              <Link
                to="/courses"
                className="flex items-center justify-between p-3 rounded-lg bg-slate-50 hover:bg-indigo-50/70 border border-slate-100 hover:border-indigo-100 transition-all text-xs font-semibold text-slate-700 hover:text-indigo-700"
              >
                <div className="flex items-center gap-3">
                  <div className="w-7 h-7 rounded-md bg-amber-100 text-amber-700 flex items-center justify-center">
                    <GraduationCap size={14} />
                  </div>
                  <span>Create Course or Edit Pricing</span>
                </div>
                <ArrowUpRight size={14} className="text-slate-400" />
              </Link>

              <Link
                to="/store"
                className="flex items-center justify-between p-3 rounded-lg bg-slate-50 hover:bg-indigo-50/70 border border-slate-100 hover:border-indigo-100 transition-all text-xs font-semibold text-slate-700 hover:text-indigo-700"
              >
                <div className="flex items-center gap-3">
                  <div className="w-7 h-7 rounded-md bg-sky-100 text-sky-700 flex items-center justify-center">
                    <ShoppingBag size={14} />
                  </div>
                  <span>Manage DIY Kits & Inventory</span>
                </div>
                <ArrowUpRight size={14} className="text-slate-400" />
              </Link>
            </div>
          </div>

          <div className="pt-4 mt-4 border-t border-slate-100 flex items-center justify-between text-xs text-slate-400">
            <span>FastAPI Server Target</span>
            <span className="font-mono text-[11px] text-slate-600 bg-slate-100 px-2 py-0.5 rounded max-w-[200px] truncate" title={BASE_URL}>
              {BASE_URL}
            </span>
          </div>
        </div>

        {/* Live Metrics Summary */}
        <div className="lg:col-span-2 bg-white p-6 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between pb-4 border-b border-slate-100">
            <div>
              <h3 className="font-bold text-slate-900 text-base">Commerce & Student Telemetry</h3>
              <p className="text-xs text-slate-500 mt-0.5">
                Aggregate values synced with primary database tables
              </p>
            </div>
            <Badge variant="success" size="sm">
              Live Database Connected
            </Badge>
          </div>

          <div className="mt-5 grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="p-4 rounded-xl bg-slate-50 border border-slate-200">
              <div className="flex items-center gap-2 text-xs font-bold text-slate-700 mb-2">
                <Package size={14} className="text-indigo-600" />
                <span>Orders Lifecycle</span>
              </div>
              <div className="space-y-2 text-xs text-slate-600">
                <div className="flex justify-between">
                  <span>Total Placed:</span>
                  <span className="font-bold text-slate-800">{stats?.orders?.total_orders || 0}</span>
                </div>
                <div className="flex justify-between">
                  <span>Paid & Cleared:</span>
                  <span className="font-bold text-emerald-600">
                    {stats?.orders?.paid_orders || 0}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span>Pending Fulfillment:</span>
                  <span className="font-bold text-amber-600">
                    {stats?.orders?.pending_orders || 0}
                  </span>
                </div>
              </div>
            </div>

            <div className="p-4 rounded-xl bg-slate-50 border border-slate-200">
              <div className="flex items-center gap-2 text-xs font-bold text-slate-700 mb-2">
                <Layers size={14} className="text-indigo-600" />
                <span>Learning Pipeline</span>
              </div>
              <div className="space-y-2 text-xs text-slate-600">
                <div className="flex justify-between">
                  <span>Active Enrollments:</span>
                  <span className="font-bold text-slate-800">
                    {stats?.entitlements?.active_enrollments || 0}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span>Published Courses:</span>
                  <span className="font-bold text-emerald-600">
                    {stats?.courses?.published_courses || 0}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span>Draft Modules:</span>
                  <span className="font-bold text-slate-500">
                    {stats?.courses?.draft_courses || 0}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
