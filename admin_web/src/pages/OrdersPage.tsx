import React, { useEffect, useState, useMemo } from 'react';
import {
  fetchAdminOrders,
  fetchAdminOrderDetail,
  updateAdminOrderStatus,
} from '../api/orders';
import { Order, OrderStatus } from '../types';
import { formatCurrency, formatDate } from '../utils/format';
import { useToast } from '../context/ToastContext';
import {
  ShoppingBag,
  Search,
  CheckCircle2,
  Clock,
  Truck,
  Package,
  AlertCircle,
  RefreshCw,
  Eye,
  Copy,
  ChevronLeft,
  ChevronRight,
  User,
  Mail,
  Phone,
  MapPin,
  CreditCard,
  Layers,
  XCircle,
  AlertTriangle,
} from 'lucide-react';
import { Badge } from '../components/Badge';
import { Modal } from '../components/Modal';
import { Button } from '../components/Button';
import { PageHeader } from '../components/PageHeader';
import { EmptyState } from '../components/EmptyState';
import { TableSkeleton } from '../components/LoadingSkeleton';

const FULFILLMENT_STEPS: OrderStatus[] = [
  'PENDING_PAYMENT',
  'PAID',
  'PROCESSING',
  'PACKED',
  'SHIPPED',
  'DELIVERED',
];

export const OrdersPage: React.FC = () => {
  const toast = useToast();
  const [orders, setOrders] = useState<Order[]>([]);
  const [totalOrders, setTotalOrders] = useState(0);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [selectedStatus, setSelectedStatus] = useState<string>('all');
  const [selectedPaymentStatus, setSelectedPaymentStatus] = useState<string>('all');
  const [page, setPage] = useState(1);
  const pageSize = 20;

  // Order Details Modal State
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);

  // Status Change State
  const [statusChangeOrder, setStatusChangeOrder] = useState<Order | null>(null);
  const [statusSubmitting, setStatusSubmitting] = useState(false);
  const [confirmCancelOpen, setConfirmCancelOpen] = useState(false);
  const [statusModalOpen, setStatusModalOpen] = useState(false);
  const [pendingNextStatus, setPendingNextStatus] = useState<OrderStatus | null>(null);
  const [trackingNumberInput, setTrackingNumberInput] = useState('');

  const loadOrders = async () => {
    setLoading(true);
    try {
      const params: any = {
        limit: pageSize,
        offset: (page - 1) * pageSize,
      };
      if (selectedStatus !== 'all') params.order_status = selectedStatus;
      if (selectedPaymentStatus !== 'all') params.payment_status = selectedPaymentStatus;
      if (search.trim()) params.search = search.trim();

      const data = await fetchAdminOrders(params);
      setOrders(data.orders || []);
      setTotalOrders(data.total || 0);
    } catch (err: any) {
      toast.error('Failed to load orders', err?.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const timer = setTimeout(() => {
      loadOrders();
    }, 200);
    return () => clearTimeout(timer);
  }, [page, selectedStatus, selectedPaymentStatus, search]);

  const copyToClipboard = (text: string, label: string = 'Text') => {
    navigator.clipboard.writeText(text);
    toast.info('Copied to Clipboard', `${label}: ${text}`);
  };

  // --------------------------------------------------------------------------
  // KPI CALCULATIONS (Dynamic from loaded list & total)
  // --------------------------------------------------------------------------
  const orderMetrics = useMemo(() => {
    const total = totalOrders || orders.length;
    const paidCount = orders.filter((o) => o.order_status === 'PAID' || o.payment_status === 'PAYMENT_SUCCESS').length;
    const processingCount = orders.filter((o) => o.order_status === 'PROCESSING' || o.order_status === 'PACKED').length;
    const shippedCount = orders.filter((o) => o.order_status === 'SHIPPED').length;
    const deliveredCount = orders.filter((o) => o.order_status === 'DELIVERED').length;
    const cancelledCount = orders.filter((o) => o.order_status === 'CANCELLED').length;
    const revenue = orders
      .filter((o) => o.payment_status === 'PAYMENT_SUCCESS')
      .reduce((sum, o) => sum + (o.total_payable || 0), 0);

    return { total, paidCount, processingCount, shippedCount, deliveredCount, cancelledCount, revenue };
  }, [orders, totalOrders]);

  // Filtered orders matching search query
  const filteredOrders = useMemo(() => {
    if (!search.trim()) return orders;
    const query = search.toLowerCase();
    return orders.filter((o) => {
      const matchId = o.id.toLowerCase().includes(query);
      const matchName = (o.customer_name || '').toLowerCase().includes(query);
      const matchEmail = (o.customer_email || '').toLowerCase().includes(query);
      const matchPhone = (o.customer_phone || '').toLowerCase().includes(query);
      const matchTrk = (o.tracking_number || '').toLowerCase().includes(query);
      return matchId || matchName || matchEmail || matchPhone || matchTrk;
    });
  }, [orders, search]);

  // --------------------------------------------------------------------------
  // ORDER DETAILS INSPECTOR
  // --------------------------------------------------------------------------
  const openOrderDetail = async (order: Order) => {
    setSelectedOrder(order);
    try {
      const fullDetail = await fetchAdminOrderDetail(order.id);
      setSelectedOrder(fullDetail);
    } catch (err: any) {
      console.error('Failed to get order details:', err);
    }
  };

  // --------------------------------------------------------------------------
  // STATUS TRANSITION HANDLERS
  // --------------------------------------------------------------------------
  const promptStatusChange = (order: Order, newStatus: OrderStatus) => {
    setStatusChangeOrder(order);
    setPendingNextStatus(newStatus);
    setTrackingNumberInput(order.tracking_number || '');

    if (newStatus === 'CANCELLED') {
      setConfirmCancelOpen(true);
    } else {
      setStatusModalOpen(true);
    }
  };

  const handleConfirmStatusUpdate = async () => {
    if (!statusChangeOrder || !pendingNextStatus) return;
    await executeStatusUpdate(
      statusChangeOrder.id,
      pendingNextStatus,
      trackingNumberInput.trim() || undefined
    );
    setStatusModalOpen(false);
  };

  const executeStatusUpdate = async (orderId: string, statusToSet: OrderStatus, trackingNum?: string) => {
    setStatusSubmitting(true);
    try {
      const res = await updateAdminOrderStatus(orderId, statusToSet, trackingNum);
      toast.success(
        'Order Status Updated',
        `Order ${orderId} moved to ${statusToSet}.`
      );

      // Update state
      setOrders((prev) =>
        prev.map((o) => (o.id === orderId ? { ...o, order_status: statusToSet, tracking_number: res.tracking_number || o.tracking_number } : o))
      );
      if (selectedOrder && selectedOrder.id === orderId) {
        setSelectedOrder({ ...selectedOrder, order_status: statusToSet, tracking_number: res.tracking_number || selectedOrder.tracking_number });
      }
      setConfirmCancelOpen(false);
      setStatusChangeOrder(null);
    } catch (err: any) {
      toast.error('Status Update Failed', err?.message);
    } finally {
      setStatusSubmitting(false);
    }
  };

  const getOrderStatusBadge = (status: OrderStatus) => {
    switch (status) {
      case 'DELIVERED':
        return (
          <Badge variant="success" size="sm" className="gap-1 items-center font-bold">
            <CheckCircle2 size={12} />
            <span>Delivered</span>
          </Badge>
        );
      case 'SHIPPED':
        return (
          <Badge variant="info" size="sm" className="gap-1 items-center font-bold">
            <Truck size={12} />
            <span>Shipped</span>
          </Badge>
        );
      case 'PACKED':
        return (
          <Badge variant="purple" size="sm" className="gap-1 items-center font-bold">
            <Package size={12} />
            <span>Packed</span>
          </Badge>
        );
      case 'PROCESSING':
        return (
          <Badge variant="warning" size="sm" className="gap-1 items-center font-bold">
            <Clock size={12} />
            <span>Processing</span>
          </Badge>
        );
      case 'PAID':
        return (
          <Badge variant="success" size="sm" className="gap-1 items-center font-bold">
            <CheckCircle2 size={12} />
            <span>Paid</span>
          </Badge>
        );
      case 'CANCELLED':
        return (
          <Badge variant="danger" size="sm" className="gap-1 items-center font-bold">
            <XCircle size={12} />
            <span>Cancelled</span>
          </Badge>
        );
      default:
        return (
          <Badge variant="default" size="sm" className="gap-1 items-center">
            <Clock size={12} />
            <span>Pending Payment</span>
          </Badge>
        );
    }
  };

  const getPaymentStatusBadge = (status: string) => {
    switch (status) {
      case 'PAYMENT_SUCCESS':
        return (
          <Badge variant="success" size="sm" className="gap-1 text-[10px]">
            <CheckCircle2 size={10} />
            <span>Paid</span>
          </Badge>
        );
      case 'PAYMENT_PENDING':
      case 'PAYMENT_PROCESSING':
        return (
          <Badge variant="warning" size="sm" className="gap-1 text-[10px]">
            <Clock size={10} />
            <span>Pending</span>
          </Badge>
        );
      case 'PAYMENT_FAILED':
      case 'PAYMENT_CANCELLED':
      case 'PAYMENT_EXPIRED':
        return (
          <Badge variant="danger" size="sm" className="gap-1 text-[10px]">
            <AlertCircle size={10} />
            <span>Failed</span>
          </Badge>
        );
      default:
        return (
          <Badge variant="default" size="sm" className="text-[10px]">
            {status}
          </Badge>
        );
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <PageHeader
        title="Orders & Fulfillment Hub"
        subtitle="Manage customer orders, track package fulfillment lifecycle, and inspect transaction breakdowns"
        breadcrumbs={[{ label: 'Admin', href: '/' }, { label: 'Orders & Fulfillment' }]}
        action={
          <div className="flex items-center gap-2.5">
            <button
              onClick={loadOrders}
              className="p-2 bg-white hover:bg-slate-50 border border-slate-200 rounded-lg text-slate-600 hover:text-slate-900 transition-colors shadow-2xs cursor-pointer"
              title="Refresh Orders"
            >
              <RefreshCw size={15} />
            </button>
          </div>
        }
      />

      {/* KPI Cards */}
      <div className="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-6 gap-3">
        <div className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-2xs">
          <span className="text-[11px] font-semibold text-slate-500">Total Orders</span>
          <p className="text-xl font-bold text-slate-900 mt-1">{orderMetrics.total}</p>
        </div>

        <div className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-2xs">
          <span className="text-[11px] font-semibold text-emerald-700">Paid Orders</span>
          <p className="text-xl font-bold text-emerald-600 mt-1">{orderMetrics.paidCount}</p>
        </div>

        <div className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-2xs">
          <span className="text-[11px] font-semibold text-amber-700">Processing / Packed</span>
          <p className="text-xl font-bold text-amber-600 mt-1">{orderMetrics.processingCount}</p>
        </div>

        <div className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-2xs">
          <span className="text-[11px] font-semibold text-sky-700">In Transit</span>
          <p className="text-xl font-bold text-sky-600 mt-1">{orderMetrics.shippedCount}</p>
        </div>

        <div className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-2xs">
          <span className="text-[11px] font-semibold text-emerald-700">Delivered</span>
          <p className="text-xl font-bold text-emerald-600 mt-1">{orderMetrics.deliveredCount}</p>
        </div>

        <div className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-2xs">
          <span className="text-[11px] font-semibold text-indigo-700">Paid Revenue</span>
          <p className="text-xl font-bold text-indigo-700 mt-1">{formatCurrency(orderMetrics.revenue)}</p>
        </div>
      </div>

      {/* Search & Multifaceted Status Filters */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs space-y-3">
        <div className="flex flex-col sm:flex-row items-center gap-3">
          <div className="relative flex-1 w-full">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search by Order ID, customer name, email, or phone..."
              className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs sm:text-sm focus:bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div className="flex items-center gap-2 w-full sm:w-auto overflow-x-auto">
            {/* Fulfillment Status Filter */}
            <select
              value={selectedStatus}
              onChange={(e) => {
                setSelectedStatus(e.target.value);
                setPage(1);
              }}
              className="px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-medium focus:bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="all">All Fulfillment Statuses</option>
              <option value="PAID">Paid (Awaiting Processing)</option>
              <option value="PROCESSING">Processing</option>
              <option value="PACKED">Packed</option>
              <option value="SHIPPED">Shipped (In Transit)</option>
              <option value="DELIVERED">Delivered</option>
              <option value="CANCELLED">Cancelled</option>
              <option value="PENDING_PAYMENT">Pending Payment</option>
            </select>

            {/* Payment Status Filter */}
            <select
              value={selectedPaymentStatus}
              onChange={(e) => {
                setSelectedPaymentStatus(e.target.value);
                setPage(1);
              }}
              className="px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-medium focus:bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="all">All Payment Statuses</option>
              <option value="PAYMENT_SUCCESS">Payment Success</option>
              <option value="PAYMENT_PENDING">Payment Pending</option>
              <option value="PAYMENT_FAILED">Payment Failed</option>
            </select>
          </div>
        </div>
      </div>

      {/* Orders Table */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-2xs overflow-hidden">
        {loading ? (
          <TableSkeleton rows={6} />
        ) : filteredOrders.length === 0 ? (
          <EmptyState
            icon={ShoppingBag}
            title="No orders found"
            description={
              search || selectedStatus !== 'all' || selectedPaymentStatus !== 'all'
                ? 'No customer orders matched your active filters.'
                : 'No store purchases or course orders have been placed yet.'
            }
          />
        ) : (
          <div className="divide-y divide-slate-100">
            {filteredOrders.map((order) => (
              <div
                key={order.id}
                className="p-4 sm:px-6 flex flex-col md:flex-row md:items-center justify-between gap-4 hover:bg-slate-50/75 transition-colors"
              >
                {/* Left: Order ID & Customer Details */}
                <div className="flex items-center gap-3.5 min-w-0">
                  <div
                    onClick={() => openOrderDetail(order)}
                    className="w-11 h-11 rounded-xl bg-indigo-50 text-indigo-700 border border-indigo-100 flex items-center justify-center font-bold text-sm shrink-0 cursor-pointer"
                  >
                    <ShoppingBag size={18} />
                  </div>

                  <div className="min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                      <button
                        onClick={() => openOrderDetail(order)}
                        className="font-mono font-bold text-slate-900 hover:text-indigo-600 text-xs sm:text-sm transition-colors cursor-pointer"
                      >
                        {order.id}
                      </button>
                      <button
                        onClick={() => copyToClipboard(order.id, 'Order ID')}
                        className="text-slate-400 hover:text-slate-700 p-0.5 cursor-pointer"
                        title="Copy Order ID"
                      >
                        <Copy size={12} />
                      </button>
                    </div>

                    <div className="flex items-center gap-2 text-xs text-slate-500 mt-1 flex-wrap">
                      <span className="font-semibold text-slate-800">{order.customer_name}</span>
                      <span>&bull;</span>
                      <span className="truncate max-w-[150px]">{order.customer_email}</span>
                      <span>&bull;</span>
                      <span>{order.created_at ? formatDate(order.created_at) : 'N/A'}</span>
                    </div>
                  </div>
                </div>

                {/* Middle: Items count, Total Payable, Payment Badge */}
                <div className="flex items-center gap-4 shrink-0 flex-wrap">
                  <div className="text-right">
                    <p className="font-bold text-slate-900 text-sm">{formatCurrency(order.total_payable)}</p>
                    <p className="text-[11px] text-slate-500">
                      {order.items?.length || 1} {order.items?.length === 1 ? 'item' : 'items'}
                    </p>
                  </div>

                  <div className="flex flex-col gap-1 items-start sm:items-end">
                    {getPaymentStatusBadge(order.payment_status)}
                    {getOrderStatusBadge(order.order_status)}
                  </div>
                </div>

                {/* Right: Quick Status Transition & Inspect */}
                <div className="flex items-center justify-end gap-2 shrink-0">
                  {/* Status Dropdown */}
                  <select
                    value={order.order_status}
                    onChange={(e) => promptStatusChange(order, e.target.value as OrderStatus)}
                    className="px-2.5 py-1.5 bg-slate-50 border border-slate-300 rounded-lg text-xs font-semibold text-slate-700 focus:bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500 cursor-pointer"
                  >
                    <option value="PENDING_PAYMENT">Pending Payment</option>
                    <option value="PAID">Paid</option>
                    <option value="PROCESSING">Processing</option>
                    <option value="PACKED">Packed</option>
                    <option value="SHIPPED">Shipped</option>
                    <option value="DELIVERED">Delivered</option>
                    <option value="CANCELLED">Cancelled</option>
                  </select>

                  <button
                    onClick={() => openOrderDetail(order)}
                    className="p-1.5 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-md transition-colors cursor-pointer"
                    title="Inspect Order Details & Fulfillment"
                  >
                    <Eye size={16} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Pagination Footer */}
        {totalOrders > pageSize && (
          <div className="px-6 py-3 border-t border-slate-100 bg-slate-50 flex items-center justify-between text-xs text-slate-600">
            <span>
              Showing {(page - 1) * pageSize + 1} - {Math.min(page * pageSize, totalOrders)} of {totalOrders} orders
            </span>
            <div className="flex items-center gap-2">
              <Button
                variant="secondary"
                size="sm"
                disabled={page <= 1}
                onClick={() => setPage(page - 1)}
                leftIcon={<ChevronLeft size={14} />}
              >
                Previous
              </Button>
              <Button
                variant="secondary"
                size="sm"
                disabled={page * pageSize >= totalOrders}
                onClick={() => setPage(page + 1)}
                rightIcon={<ChevronRight size={14} />}
              >
                Next
              </Button>
            </div>
          </div>
        )}
      </div>

      {/* ── 1. ORDER DETAILS INSPECTOR MODAL ──────────────────────────────── */}
      <Modal
        isOpen={!!selectedOrder}
        onClose={() => setSelectedOrder(null)}
        title={`Order Details: ${selectedOrder?.id}`}
        subtitle="Customer transaction breakdown, shipping information, and fulfillment stepper"
        maxWidth="2xl"
      >
        {selectedOrder && (
          <div className="space-y-5 text-xs">
            {/* Fulfillment Lifecycle Stepper */}
            <div className="p-4 bg-slate-50 rounded-xl border border-slate-200">
              <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400 block mb-3">
                Fulfillment Lifecycle Progress
              </span>

              {selectedOrder.order_status === 'CANCELLED' ? (
                <div className="p-3 bg-rose-50 border border-rose-200 rounded-lg flex items-center gap-2 text-rose-800 font-bold">
                  <XCircle size={16} className="text-rose-600 shrink-0" />
                  <span>This order was marked as CANCELLED.</span>
                </div>
              ) : (
                <div className="grid grid-cols-3 sm:grid-cols-6 gap-2">
                  {FULFILLMENT_STEPS.map((step, idx) => {
                    const currentIdx = FULFILLMENT_STEPS.indexOf(selectedOrder.order_status);
                    const isPassed = currentIdx >= idx;
                    const isCurrent = selectedOrder.order_status === step;

                    return (
                      <div
                        key={step}
                        className={`p-2 rounded-lg text-center transition-all ${
                          isCurrent
                            ? 'bg-indigo-600 text-white font-bold shadow-xs'
                            : isPassed
                            ? 'bg-emerald-50 text-emerald-800 border border-emerald-200 font-medium'
                            : 'bg-white text-slate-400 border border-slate-200'
                        }`}
                      >
                        <div className="text-[10px] uppercase tracking-tighter truncate">
                          {step.replace('_', ' ')}
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>

            {/* Customer & Shipping Information */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {/* Customer Card */}
              <div className="p-4 bg-white rounded-xl border border-slate-200 shadow-2xs space-y-2.5">
                <div className="flex items-center gap-2 text-indigo-700 font-bold">
                  <User size={15} />
                  <span>Customer Contact</span>
                </div>
                <div className="space-y-1.5 text-slate-700">
                  <p className="font-semibold text-slate-900">{selectedOrder.customer_name || 'N/A'}</p>
                  <p className="flex items-center gap-1.5 text-slate-600">
                    <Mail size={13} className="text-slate-400 shrink-0" />
                    <span className="truncate">{selectedOrder.customer_email || 'N/A'}</span>
                  </p>
                  <p className="flex items-center gap-1.5 text-slate-600">
                    <Phone size={13} className="text-slate-400 shrink-0" />
                    <span>{selectedOrder.customer_phone || 'N/A'}</span>
                  </p>
                  {selectedOrder.user_id && (
                    <p className="text-[11px] text-slate-400 font-mono pt-1">
                      UID: {selectedOrder.user_id.substring(0, 16)}...
                    </p>
                  )}
                </div>
              </div>

              {/* Shipping Address Card */}
              <div className="p-4 bg-white rounded-xl border border-slate-200 shadow-2xs space-y-2.5">
                <div className="flex items-center gap-2 text-indigo-700 font-bold">
                  <MapPin size={15} />
                  <span>Shipping Address</span>
                </div>
                {selectedOrder.shipping_address ? (
                  <div className="space-y-1 text-slate-700 leading-relaxed">
                    <p className="font-semibold text-slate-900">
                      {selectedOrder.shipping_address.fullName || selectedOrder.customer_name}
                    </p>
                    <p className="text-slate-600">
                      {selectedOrder.shipping_address.addressLine1}
                      {selectedOrder.shipping_address.addressLine2
                        ? `, ${selectedOrder.shipping_address.addressLine2}`
                        : ''}
                    </p>
                    <p className="text-slate-600">
                      {selectedOrder.shipping_address.city}, {selectedOrder.shipping_address.state} -{' '}
                      <strong className="text-slate-800">{selectedOrder.shipping_address.pincode}</strong>
                    </p>
                    {selectedOrder.shipping_address.phone && (
                      <p className="text-[11px] text-slate-500">Contact: {selectedOrder.shipping_address.phone}</p>
                    )}
                  </div>
                ) : (
                  <p className="text-slate-400 italic">
                    Digital item / No physical shipping address required for this order.
                  </p>
                )}
              </div>
            </div>

            {/* Itemized Order Breakdown */}
            <div className="p-4 bg-white rounded-xl border border-slate-200 shadow-2xs space-y-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2 text-indigo-700 font-bold">
                  <Layers size={15} />
                  <span>Purchased Items & Kits ({selectedOrder.items?.length || 1})</span>
                </div>
              </div>

              <div className="divide-y divide-slate-100">
                {selectedOrder.items && selectedOrder.items.length > 0 ? (
                  selectedOrder.items.map((item, i) => (
                    <div key={i} className="py-2.5 flex items-center justify-between gap-3">
                      <div className="min-w-0">
                        <p className="font-semibold text-slate-900 truncate">{item.title || `Item #${item.item_id}`}</p>
                        <div className="flex items-center gap-2 text-[11px] text-slate-500 mt-0.5">
                          <Badge variant="outline" size="sm">
                            {item.item_type}
                          </Badge>
                          <span>Qty: {item.quantity || 1}</span>
                          <span>&bull;</span>
                          <span>Unit: {formatCurrency(item.price)}</span>
                        </div>
                      </div>
                      <p className="font-bold text-slate-900 shrink-0">
                        {formatCurrency((item.price || 0) * (item.quantity || 1))}
                      </p>
                    </div>
                  ))
                ) : (
                  <div className="py-2.5 flex items-center justify-between text-slate-600">
                    <span>Standard Order Items</span>
                    <span className="font-bold">{formatCurrency(selectedOrder.items_total)}</span>
                  </div>
                )}
              </div>

              {/* Authoritative Financial Breakdown */}
              <div className="pt-3 border-t border-slate-100 space-y-1.5 text-xs">
                <div className="flex justify-between text-slate-600">
                  <span>Items Subtotal</span>
                  <span>{formatCurrency(selectedOrder.items_total)}</span>
                </div>

                <div className="flex justify-between text-slate-600">
                  <span>
                    Delivery Fee{' '}
                    <span className="text-[10px] text-slate-400">
                      ({selectedOrder.delivery_fee_rule || selectedOrder.delivery_region || 'Standard'})
                    </span>
                  </span>
                  <span>{selectedOrder.delivery_fee === 0 ? 'FREE' : formatCurrency(selectedOrder.delivery_fee)}</span>
                </div>

                {selectedOrder.discount_amount > 0 && (
                  <div className="flex justify-between text-emerald-600 font-medium">
                    <span>Discount Applied</span>
                    <span>-{formatCurrency(selectedOrder.discount_amount)}</span>
                  </div>
                )}

                <div className="flex justify-between text-sm font-bold text-slate-900 pt-2 border-t border-slate-200">
                  <span>Total Amount Paid</span>
                  <span className="text-indigo-700">{formatCurrency(selectedOrder.total_payable)}</span>
                </div>
              </div>
            </div>

            {/* Payment Gateway Metadata */}
            <div className="p-4 bg-slate-50 rounded-xl border border-slate-200 space-y-2">
              <div className="flex items-center gap-2 text-slate-700 font-bold">
                <CreditCard size={15} />
                <span>Payment Details</span>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-slate-600 text-[11px]">
                <p>
                  <strong>Gateway Method:</strong> {selectedOrder.payment_method || 'Online Payment'}
                </p>
                <p>
                  <strong>Payment Status:</strong> {selectedOrder.payment_status}
                </p>
                {selectedOrder.cashfree_order_id && (
                  <p className="font-mono">
                    <strong>Cashfree Order ID:</strong> {selectedOrder.cashfree_order_id}
                  </p>
                )}
                {selectedOrder.cashfree_payment_id && (
                  <p className="font-mono">
                    <strong>Cashfree Payment ID:</strong> {selectedOrder.cashfree_payment_id}
                  </p>
                )}
                {selectedOrder.razorpay_order_id && (
                  <p className="font-mono">
                    <strong>Razorpay Order ID:</strong> {selectedOrder.razorpay_order_id}
                  </p>
                )}
              </div>
            </div>

            {/* Actions */}
            <div className="flex items-center justify-between pt-2 border-t border-slate-100">
              <div className="flex items-center gap-2">
                <span className="text-slate-500 font-semibold">Change Status:</span>
                <select
                  value={selectedOrder.order_status}
                  onChange={(e) => promptStatusChange(selectedOrder, e.target.value as OrderStatus)}
                  className="px-2.5 py-1.5 bg-white border border-slate-300 rounded-lg font-semibold text-slate-800 focus:ring-2 focus:ring-indigo-500"
                >
                  <option value="PENDING_PAYMENT">Pending Payment</option>
                  <option value="PAID">Paid</option>
                  <option value="PROCESSING">Processing</option>
                  <option value="PACKED">Packed</option>
                  <option value="SHIPPED">Shipped</option>
                  <option value="DELIVERED">Delivered</option>
                  <option value="CANCELLED">Cancelled</option>
                </select>
              </div>

              <Button variant="secondary" onClick={() => setSelectedOrder(null)}>
                Close
              </Button>
            </div>
          </div>
        )}
      </Modal>

      {/* ── 2. CONFIRM CANCEL ORDER MODAL ─────────────────────────────────── */}
      <Modal
        isOpen={confirmCancelOpen}
        onClose={() => setConfirmCancelOpen(false)}
        title="Confirm Order Cancellation"
        subtitle="This action will mark the customer order as cancelled"
        maxWidth="md"
      >
        <div className="space-y-4 text-xs sm:text-sm text-slate-600">
          <div className="p-3.5 bg-rose-50 border border-rose-200 rounded-xl text-rose-800 text-xs flex items-start gap-2.5">
            <AlertTriangle size={18} className="text-rose-600 shrink-0 mt-0.5" />
            <div>
              <p className="font-bold">Mark as Cancelled</p>
              <p className="mt-0.5">
                Are you sure you want to cancel order <strong>"{statusChangeOrder?.id}"</strong> for{' '}
                {statusChangeOrder?.customer_name}?
              </p>
            </div>
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <Button variant="secondary" onClick={() => setConfirmCancelOpen(false)}>
              Back
            </Button>
            <Button
              variant="danger"
              isLoading={statusSubmitting}
              onClick={() => {
                if (statusChangeOrder) {
                  executeStatusUpdate(statusChangeOrder.id, 'CANCELLED');
                }
              }}
            >
              Confirm Cancellation
            </Button>
          </div>
        </div>
      </Modal>

      {/* ── 3. CONFIRM STATUS TRANSITION & TRACKING ID MODAL ──────────────── */}
      <Modal
        isOpen={statusModalOpen}
        onClose={() => setStatusModalOpen(false)}
        title="Update Order Fulfillment Status"
        subtitle={`Advance order ${statusChangeOrder?.id || ''} lifecycle`}
        maxWidth="md"
      >
        <div className="space-y-4 text-xs sm:text-sm text-slate-600">
          <div className="p-3.5 bg-slate-50 border border-slate-200 rounded-xl space-y-2">
            <div className="flex justify-between items-center">
              <span className="text-xs text-slate-500 font-semibold">Order ID:</span>
              <span className="font-mono font-bold text-slate-900">{statusChangeOrder?.id}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-xs text-slate-500 font-semibold">Customer:</span>
              <span className="font-semibold text-slate-800">{statusChangeOrder?.customer_name}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-xs text-slate-500 font-semibold">Target Status:</span>
              <Badge variant="purple" size="sm" className="font-bold">
                {pendingNextStatus}
              </Badge>
            </div>
          </div>

          {/* Tracking Number Input for Physical Orders */}
          {(pendingNextStatus === 'PROCESSING' || pendingNextStatus === 'PACKED' || pendingNextStatus === 'SHIPPED') && (
            <div className="space-y-1.5">
              <label className="block text-xs font-bold text-slate-700">
                Courier / Tracking Reference Number:
              </label>
              <input
                type="text"
                value={trackingNumberInput}
                onChange={(e) => setTrackingNumberInput(e.target.value)}
                placeholder="e.g. EDK-TRK-7482910 or SpeedPost ID (optional)"
                className="w-full px-3 py-2 bg-white border border-slate-300 rounded-lg text-xs sm:text-sm font-mono focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              />
              <p className="text-[11px] text-slate-400">
                If left empty, backend will auto-generate a unique EDK-TRK ID.
              </p>
            </div>
          )}

          <p className="text-[11px] text-slate-500 italic">
            Note: Customer will see this update live in their app order timeline.
          </p>

          <div className="flex justify-end gap-3 pt-2">
            <Button variant="secondary" onClick={() => setStatusModalOpen(false)}>
              Cancel
            </Button>
            <Button
              variant="primary"
              isLoading={statusSubmitting}
              onClick={handleConfirmStatusUpdate}
            >
              Update to {pendingNextStatus}
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
};
