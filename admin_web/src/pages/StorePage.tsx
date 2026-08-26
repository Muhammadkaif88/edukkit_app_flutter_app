import React, { useEffect, useState, useMemo } from 'react';
import { Link } from 'react-router-dom';
import {
  fetchAdminProducts,
  createAdminProduct,
  updateAdminProduct,
  toggleProductActive,
  deleteAdminProduct,
} from '../api/products';
import { fetchAdminCourses } from '../api/courses';
import { Product, Course } from '../types';
import { formatCurrency } from '../utils/format';
import { useToast } from '../context/ToastContext';
import {
  ShoppingBag,
  Plus,
  Edit2,
  Trash2,
  Search,
  CheckCircle2,
  AlertTriangle,
  AlertCircle,
  RefreshCw,
  Eye,
  GraduationCap,
  Package,
  Boxes,
  Image as ImageIcon,
  ExternalLink,
} from 'lucide-react';
import { Badge } from '../components/Badge';
import { Modal } from '../components/Modal';
import { Button } from '../components/Button';
import { PageHeader } from '../components/PageHeader';
import { EmptyState } from '../components/EmptyState';
import { TableSkeleton } from '../components/LoadingSkeleton';

type StockFilter = 'all' | 'in_stock' | 'low_stock' | 'out_of_stock';
type TypeFilter = 'all' | 'diy_kit' | 'electronics';
type ActiveFilter = 'all' | 'active' | 'inactive';

export const StorePage: React.FC = () => {
  const toast = useToast();
  const [products, setProducts] = useState<Product[]>([]);
  const [courses, setCourses] = useState<Course[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [selectedType, setSelectedType] = useState<TypeFilter>('all');
  const [stockFilter, setStockFilter] = useState<StockFilter>('all');
  const [activeFilter, setActiveFilter] = useState<ActiveFilter>('all');

  // Create / Edit Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState<Product | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [formErrors, setFormErrors] = useState<Record<string, string>>({});

  // Form Fields
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    price: 0,
    original_price: 0,
    stock: 10,
    category: 'Robotics Kits',
    type: 'diy_kit' as 'diy_kit' | 'electronics',
    imageUrl: '',
    is_active: true,
    linked_course_id: null as number | null,
  });

  // Details Inspector Modal State
  const [inspectingProduct, setInspectingProduct] = useState<Product | null>(null);

  // Quick Stock Adjustment State
  const [quickStockProduct, setQuickStockProduct] = useState<Product | null>(null);
  const [quickStockValue, setQuickStockValue] = useState<number>(0);
  const [quickStockSubmitting, setQuickStockSubmitting] = useState(false);

  // Delete Confirmation Modal State
  const [deletingProduct, setDeletingProduct] = useState<Product | null>(null);
  const [deleteSubmitting, setDeleteSubmitting] = useState(false);

  const loadData = async () => {
    setLoading(true);
    try {
      const [productsData, coursesData] = await Promise.all([
        fetchAdminProducts(),
        fetchAdminCourses().catch(() => []),
      ]);
      setProducts(productsData);
      setCourses(coursesData);
    } catch (err: any) {
      toast.error('Failed to load store inventory', err?.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  // --------------------------------------------------------------------------
  // DYNAMIC CATEGORY COUNTS (Preserves Phase 3 Category Count Synchronization)
  // --------------------------------------------------------------------------
  const categoryCounts = useMemo(() => {
    const counts: Record<string, number> = { all: products.length };
    products.forEach((p) => {
      const cat = p.category?.trim() || 'Uncategorized';
      counts[cat] = (counts[cat] || 0) + 1;
    });
    return counts;
  }, [products]);

  const uniqueCategories = useMemo(() => {
    const cats = Array.from(
      new Set(products.map((p) => p.category?.trim()).filter(Boolean))
    ) as string[];
    return ['all', ...cats];
  }, [products]);

  // Inventory KPI metrics
  const inventoryMetrics = useMemo(() => {
    const total = products.length;
    const lowStock = products.filter((p) => p.stock > 0 && p.stock <= 5 && p.is_active).length;
    const outOfStock = products.filter((p) => p.stock === 0 && p.is_active).length;
    const inStock = products.filter((p) => p.stock > 5 && p.is_active).length;
    const inactive = products.filter((p) => !p.is_active).length;
    return { total, lowStock, outOfStock, inStock, inactive };
  }, [products]);

  // Filtered Products List
  const filteredProducts = useMemo(() => {
    return products.filter((p) => {
      // Search
      if (search.trim()) {
        const query = search.toLowerCase();
        const matchesName = p.name.toLowerCase().includes(query);
        const matchesCat = (p.category || '').toLowerCase().includes(query);
        const matchesDesc = (p.description || '').toLowerCase().includes(query);
        if (!matchesName && !matchesCat && !matchesDesc) return false;
      }
      // Category
      if (selectedCategory !== 'all' && (p.category || 'Uncategorized') !== selectedCategory) {
        return false;
      }
      // Product Type
      if (selectedType !== 'all' && p.type !== selectedType) {
        return false;
      }
      // Stock Status
      if (stockFilter === 'in_stock' && p.stock <= 5) return false;
      if (stockFilter === 'low_stock' && (p.stock <= 0 || p.stock > 5)) return false;
      if (stockFilter === 'out_of_stock' && p.stock > 0) return false;
      // Active Status
      if (activeFilter === 'active' && !p.is_active) return false;
      if (activeFilter === 'inactive' && p.is_active) return false;

      return true;
    });
  }, [products, search, selectedCategory, selectedType, stockFilter, activeFilter]);

  // --------------------------------------------------------------------------
  // CREATE / EDIT HANDLERS
  // --------------------------------------------------------------------------
  const openCreateModal = () => {
    setEditingProduct(null);
    setFormData({
      name: '',
      description: '',
      price: 999,
      original_price: 1499,
      stock: 15,
      category: 'Robotics Kits',
      type: 'diy_kit',
      imageUrl: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800&q=80',
      is_active: true,
      linked_course_id: null,
    });
    setFormErrors({});
    setIsModalOpen(true);
  };

  const openEditModal = (product: Product) => {
    setEditingProduct(product);
    const firstImage = product.images && product.images.length > 0 ? product.images[0] : '';
    setFormData({
      name: product.name,
      description: product.description || '',
      price: product.price,
      original_price: product.original_price || 0,
      stock: product.stock,
      category: product.category || 'Robotics Kits',
      type: product.type,
      imageUrl: firstImage,
      is_active: product.is_active,
      linked_course_id: product.linked_course_id || null,
    });
    setFormErrors({});
    setIsModalOpen(true);
  };

  const handleFormSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const errors: Record<string, string> = {};

    if (!formData.name.trim()) errors.name = 'Product name is required';
    if (formData.price < 0) errors.price = 'Price cannot be negative';
    if (formData.stock < 0) errors.stock = 'Stock quantity cannot be negative';

    if (Object.keys(errors).length > 0) {
      setFormErrors(errors);
      return;
    }

    setSubmitting(true);
    try {
      const payload: Partial<Product> = {
        name: formData.name.trim(),
        description: formData.description.trim() || undefined,
        price: Number(formData.price),
        original_price: formData.original_price ? Number(formData.original_price) : undefined,
        stock: Number(formData.stock),
        category: formData.category.trim(),
        type: formData.type,
        images: formData.imageUrl.trim() ? [formData.imageUrl.trim()] : [],
        is_active: formData.is_active,
        linked_course_id: formData.linked_course_id || undefined,
      };

      if (editingProduct) {
        await updateAdminProduct(editingProduct.id, payload);
        toast.success('Product Updated', `"${formData.name}" has been updated.`);
      } else {
        await createAdminProduct(payload);
        toast.success('Product Created', `"${formData.name}" added to catalog.`);
      }

      setIsModalOpen(false);
      await loadData();
    } catch (err: any) {
      toast.error(
        editingProduct ? 'Failed to update product' : 'Failed to create product',
        err?.message
      );
    } finally {
      setSubmitting(false);
    }
  };

  // --------------------------------------------------------------------------
  // QUICK 1-CLICK ACTIVE TOGGLE
  // --------------------------------------------------------------------------
  const handleToggleActive = async (product: Product) => {
    const nextState = !product.is_active;
    // Optimistic update
    setProducts((prev) =>
      prev.map((p) => (p.id === product.id ? { ...p, is_active: nextState } : p))
    );

    try {
      await toggleProductActive(product.id, nextState);
      toast.success(
        nextState ? 'Product Activated' : 'Product Hidden',
        `"${product.name}" is now ${nextState ? 'visible in store' : 'hidden from catalog'}.`
      );
    } catch (err: any) {
      // Revert optimistic update
      setProducts((prev) =>
        prev.map((p) => (p.id === product.id ? { ...p, is_active: product.is_active } : p))
      );
      toast.error('Status Update Failed', err?.message);
    }
  };

  // --------------------------------------------------------------------------
  // QUICK STOCK ADJUSTMENT
  // --------------------------------------------------------------------------
  const openQuickStockModal = (product: Product) => {
    setQuickStockProduct(product);
    setQuickStockValue(product.stock);
  };

  const handleQuickStockSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!quickStockProduct) return;
    if (quickStockValue < 0) {
      toast.error('Invalid Stock', 'Stock quantity cannot be negative.');
      return;
    }

    setQuickStockSubmitting(true);
    try {
      await updateAdminProduct(quickStockProduct.id, { stock: Number(quickStockValue) });
      toast.success(
        'Inventory Updated',
        `Stock for "${quickStockProduct.name}" set to ${quickStockValue} units.`
      );
      setQuickStockProduct(null);
      await loadData();
    } catch (err: any) {
      toast.error('Failed to update inventory', err?.message);
    } finally {
      setQuickStockSubmitting(false);
    }
  };

  // --------------------------------------------------------------------------
  // PRODUCT DELETION
  // --------------------------------------------------------------------------
  const handleDeleteSubmit = async () => {
    if (!deletingProduct) return;
    setDeleteSubmitting(true);
    try {
      await deleteAdminProduct(deletingProduct.id);
      toast.success('Product Deleted', `"${deletingProduct.name}" removed from catalog.`);
      setDeletingProduct(null);
      await loadData();
    } catch (err: any) {
      toast.error('Deletion Failed', err?.message || 'Could not delete product.');
    } finally {
      setDeleteSubmitting(false);
    }
  };

  const getStockBadge = (stock: number, isActive: boolean) => {
    if (!isActive) {
      return (
        <Badge variant="default" size="sm">
          Inactive
        </Badge>
      );
    }
    if (stock === 0) {
      return (
        <Badge variant="danger" size="sm" className="gap-1 items-center">
          <AlertCircle size={11} />
          <span>Out of Stock (0)</span>
        </Badge>
      );
    }
    if (stock <= 5) {
      return (
        <Badge variant="warning" size="sm" className="gap-1 items-center font-bold">
          <AlertTriangle size={11} />
          <span>Low Stock ({stock})</span>
        </Badge>
      );
    }
    return (
      <Badge variant="success" size="sm" className="gap-1 items-center">
        <CheckCircle2 size={11} />
        <span>In Stock ({stock})</span>
      </Badge>
    );
  };

  const getLinkedCourseTitle = (courseId?: number) => {
    if (!courseId) return null;
    const course = courses.find((c) => c.id === courseId);
    return course ? course.title : `Course #${courseId}`;
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <PageHeader
        title="Store & Inventory Studio"
        subtitle="Manage store products, stock levels, DIY tutorial kit associations, and pricing"
        breadcrumbs={[{ label: 'Admin', href: '/' }, { label: 'Store & Inventory' }]}
        action={
          <div className="flex items-center gap-2.5">
            <button
              onClick={loadData}
              className="p-2 bg-white hover:bg-slate-50 border border-slate-200 rounded-lg text-slate-600 hover:text-slate-900 transition-colors shadow-2xs cursor-pointer"
              title="Refresh Store Products"
            >
              <RefreshCw size={15} />
            </button>
            <Button onClick={openCreateModal} leftIcon={<Plus size={16} />}>
              Add Product
            </Button>
          </div>
        }
      />

      {/* Inventory KPI Summary Cards */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3.5">
        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-500">Total Products</span>
            <Boxes size={16} className="text-indigo-600" />
          </div>
          <p className="text-2xl font-bold text-slate-900 mt-1.5">{inventoryMetrics.total}</p>
          <span className="text-[11px] text-slate-400">Authoritative Catalog</span>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-500">Healthy Stock</span>
            <Package size={16} className="text-emerald-600" />
          </div>
          <p className="text-2xl font-bold text-emerald-600 mt-1.5">{inventoryMetrics.inStock}</p>
          <span className="text-[11px] text-slate-400">&gt; 5 units available</span>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-500">Low Stock Alert</span>
            <AlertTriangle size={16} className="text-amber-500" />
          </div>
          <p className="text-2xl font-bold text-amber-600 mt-1.5">{inventoryMetrics.lowStock}</p>
          <span className="text-[11px] text-amber-700 font-medium">1–5 units remaining</span>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-500">Out of Stock</span>
            <AlertCircle size={16} className="text-rose-600" />
          </div>
          <p className="text-2xl font-bold text-rose-600 mt-1.5">{inventoryMetrics.outOfStock}</p>
          <span className="text-[11px] text-rose-700 font-medium">0 inventory</span>
        </div>
      </div>

      {/* Dynamic Category Tabs */}
      <div className="flex items-center gap-2 overflow-x-auto pb-1 text-xs">
        {uniqueCategories.map((cat) => {
          const count = categoryCounts[cat] || 0;
          const isSelected = selectedCategory === cat;
          return (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-3 py-1.5 rounded-lg font-semibold whitespace-nowrap transition-colors flex items-center gap-1.5 cursor-pointer ${
                isSelected
                  ? 'bg-indigo-600 text-white shadow-xs'
                  : 'bg-white text-slate-600 hover:bg-slate-50 border border-slate-200'
              }`}
            >
              <span>{cat === 'all' ? 'All Categories' : cat}</span>
              <span
                className={`px-1.5 py-0.2 rounded-full text-[10px] ${
                  isSelected ? 'bg-indigo-700 text-white' : 'bg-slate-100 text-slate-600'
                }`}
              >
                {count}
              </span>
            </button>
          );
        })}
      </div>

      {/* Search & Multifaceted Filters */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs space-y-3">
        <div className="flex flex-col sm:flex-row items-center gap-3">
          <div className="relative flex-1 w-full">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search products by name, description, or category..."
              className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs sm:text-sm focus:bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div className="flex items-center gap-2 w-full sm:w-auto overflow-x-auto">
            {/* Product Type Filter */}
            <select
              value={selectedType}
              onChange={(e) => setSelectedType(e.target.value as TypeFilter)}
              className="px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-medium focus:bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="all">All Types</option>
              <option value="diy_kit">DIY Kits</option>
              <option value="electronics">Electronics</option>
            </select>

            {/* Stock Level Filter */}
            <select
              value={stockFilter}
              onChange={(e) => setStockFilter(e.target.value as StockFilter)}
              className="px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-medium focus:bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="all">All Stock Levels</option>
              <option value="in_stock">In Stock (&gt; 5)</option>
              <option value="low_stock">Low Stock (1–5)</option>
              <option value="out_of_stock">Out of Stock (0)</option>
            </select>

            {/* Active Status Filter */}
            <select
              value={activeFilter}
              onChange={(e) => setActiveFilter(e.target.value as ActiveFilter)}
              className="px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-medium focus:bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="all">All Status</option>
              <option value="active">Active Only</option>
              <option value="inactive">Inactive Only</option>
            </select>
          </div>
        </div>
      </div>

      {/* Product List Table */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-2xs overflow-hidden">
        {loading ? (
          <TableSkeleton rows={6} />
        ) : filteredProducts.length === 0 ? (
          <EmptyState
            icon={ShoppingBag}
            title="No products found"
            description={
              search || selectedCategory !== 'all' || stockFilter !== 'all' || selectedType !== 'all'
                ? 'No products matched your active filters. Try clearing search filters.'
                : 'No store products in catalog. Add your first DIY kit or electronics component.'
            }
            actionLabel="+ Add First Product"
            onAction={openCreateModal}
          />
        ) : (
          <div className="divide-y divide-slate-100">
            {filteredProducts.map((product) => {
              const firstImage = product.images && product.images.length > 0 ? product.images[0] : null;
              const linkedCourseTitle = getLinkedCourseTitle(product.linked_course_id);

              return (
                <div
                  key={product.id}
                  className={`p-4 sm:px-6 flex flex-col md:flex-row md:items-center justify-between gap-4 hover:bg-slate-50/75 transition-colors ${
                    !product.is_active ? 'opacity-70 bg-slate-50/40' : ''
                  }`}
                >
                  {/* Left: Product Image & Details */}
                  <div className="flex items-center gap-4 min-w-0">
                    {firstImage ? (
                      <img
                        src={firstImage}
                        alt=""
                        onClick={() => setInspectingProduct(product)}
                        className="w-16 h-16 rounded-xl object-cover border border-slate-200 bg-slate-100 shrink-0 cursor-pointer shadow-2xs"
                      />
                    ) : (
                      <div
                        onClick={() => setInspectingProduct(product)}
                        className="w-16 h-16 rounded-xl bg-slate-100 border border-slate-200 flex items-center justify-center text-slate-400 shrink-0 cursor-pointer"
                      >
                        <ImageIcon size={22} />
                      </div>
                    )}

                    <div className="min-w-0">
                      <div className="flex items-center gap-2 flex-wrap">
                        <button
                          onClick={() => setInspectingProduct(product)}
                          className="font-bold text-slate-900 hover:text-indigo-600 text-sm truncate text-left transition-colors cursor-pointer"
                        >
                          {product.name}
                        </button>
                        <Badge
                          variant={product.type === 'diy_kit' ? 'purple' : 'info'}
                          size="sm"
                          className="text-[10px]"
                        >
                          {product.type === 'diy_kit' ? 'DIY Kit' : 'Electronics'}
                        </Badge>
                      </div>

                      <div className="flex items-center gap-2.5 text-xs text-slate-500 mt-1 flex-wrap">
                        <span className="font-semibold text-slate-700">{product.category || 'General'}</span>
                        <span>&bull;</span>
                        <span className="font-bold text-indigo-700">{formatCurrency(product.price)}</span>
                        {product.original_price && product.original_price > product.price && (
                          <span className="line-through text-slate-400">
                            {formatCurrency(product.original_price)}
                          </span>
                        )}
                        {linkedCourseTitle && (
                          <>
                            <span>&bull;</span>
                            <span className="inline-flex items-center gap-1 text-emerald-700 bg-emerald-50 px-1.5 py-0.5 rounded text-[11px] font-medium">
                              <GraduationCap size={12} />
                              <span className="truncate max-w-[120px]">{linkedCourseTitle}</span>
                            </span>
                          </>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* Middle: Stock Level & Quick Adjust */}
                  <div className="flex items-center gap-3 shrink-0 flex-wrap">
                    <button
                      onClick={() => openQuickStockModal(product)}
                      className="cursor-pointer hover:opacity-85 transition-opacity"
                      title="Click to adjust stock count"
                    >
                      {getStockBadge(product.stock, product.is_active)}
                    </button>

                    {/* Active Toggle Switch */}
                    <button
                      onClick={() => handleToggleActive(product)}
                      className={`px-2.5 py-1 rounded-md text-xs font-semibold flex items-center gap-1.5 transition-colors cursor-pointer ${
                        product.is_active
                          ? 'bg-emerald-50 text-emerald-700 hover:bg-emerald-100 border border-emerald-200'
                          : 'bg-slate-100 text-slate-500 hover:bg-slate-200 border border-slate-200'
                      }`}
                      title={product.is_active ? 'Click to hide from store' : 'Click to activate in store'}
                    >
                      <span className={`w-1.5 h-1.5 rounded-full ${product.is_active ? 'bg-emerald-600' : 'bg-slate-400'}`} />
                      <span>{product.is_active ? 'Active' : 'Hidden'}</span>
                    </button>
                  </div>

                  {/* Right: Actions */}
                  <div className="flex items-center justify-end gap-1.5 shrink-0">
                    <button
                      onClick={() => setInspectingProduct(product)}
                      className="p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-md transition-colors cursor-pointer"
                      title="Inspect Details"
                    >
                      <Eye size={16} />
                    </button>

                    <button
                      onClick={() => openEditModal(product)}
                      className="p-1.5 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-md transition-colors cursor-pointer"
                      title="Edit Product"
                    >
                      <Edit2 size={16} />
                    </button>

                    <button
                      onClick={() => setDeletingProduct(product)}
                      className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-md transition-colors cursor-pointer"
                      title="Delete Product"
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* ── 1. CREATE / EDIT PRODUCT MODAL ────────────────────────────────── */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingProduct ? 'Edit Store Product' : 'Add New Product'}
        subtitle={
          editingProduct
            ? `Update catalog details and inventory for '${editingProduct.name}'`
            : 'Publish physical kits or electronic components to Edukkit Store'
        }
        maxWidth="xl"
      >
        <form onSubmit={handleFormSubmit} className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {/* Product Name */}
            <div className="sm:col-span-2">
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Product Title *
              </label>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                placeholder="e.g. Smart IoT Weather Station Kit (ESP32)"
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                required
              />
              {formErrors.name && <p className="text-xs text-rose-600 mt-1">{formErrors.name}</p>}
            </div>

            {/* Type */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">Product Type *</label>
              <select
                value={formData.type}
                onChange={(e) =>
                  setFormData({ ...formData, type: e.target.value as 'diy_kit' | 'electronics' })
                }
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              >
                <option value="diy_kit">DIY Kit (Free Delivery + Tutorial Course)</option>
                <option value="electronics">Electronics Component (Delivery Charged)</option>
              </select>
            </div>

            {/* Category */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">Category *</label>
              <select
                value={formData.category}
                onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              >
                <option value="Robotics Kits">Robotics Kits</option>
                <option value="IoT & Smart Devices">IoT & Smart Devices</option>
                <option value="Sensors & Modules">Sensors & Modules</option>
                <option value="Microcontrollers">Microcontrollers</option>
                <option value="DIY Kits">DIY Kits</option>
                <option value="Electronics">Electronics</option>
                <option value="STEM Education">STEM Education</option>
              </select>
            </div>

            {/* Price */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">Selling Price (₹) *</label>
              <input
                type="number"
                min="0"
                step="1"
                value={formData.price}
                onChange={(e) => setFormData({ ...formData, price: Number(e.target.value) })}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                required
              />
              {formErrors.price && <p className="text-xs text-rose-600 mt-1">{formErrors.price}</p>}
            </div>

            {/* Original Price */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">Original MRP (₹)</label>
              <input
                type="number"
                min="0"
                step="1"
                value={formData.original_price}
                onChange={(e) => setFormData({ ...formData, original_price: Number(e.target.value) })}
                placeholder="Optional strike-through price"
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              />
            </div>

            {/* Stock Quantity */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Stock Quantity (Units) *
              </label>
              <input
                type="number"
                min="0"
                step="1"
                value={formData.stock}
                onChange={(e) => setFormData({ ...formData, stock: Number(e.target.value) })}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                required
              />
              {formErrors.stock && <p className="text-xs text-rose-600 mt-1">{formErrors.stock}</p>}
            </div>

            {/* Linked Course (Optional) */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Linked Tutorial Course (Granted with Kit)
              </label>
              <select
                value={formData.linked_course_id || ''}
                onChange={(e) =>
                  setFormData({
                    ...formData,
                    linked_course_id: e.target.value ? Number(e.target.value) : null,
                  })
                }
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              >
                <option value="">-- No Linked Course --</option>
                {courses.map((c) => (
                  <option key={c.id} value={c.id}>
                    #{c.id} - {c.title}
                  </option>
                ))}
              </select>
            </div>

            {/* Product Image URL */}
            <div className="sm:col-span-2">
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Product Image URL
              </label>
              <input
                type="url"
                value={formData.imageUrl}
                onChange={(e) => setFormData({ ...formData, imageUrl: e.target.value })}
                placeholder="https://images.unsplash.com/..."
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              />
              {formData.imageUrl && (
                <div className="mt-2 flex items-center gap-3 p-2 bg-slate-50 border border-slate-200 rounded-lg">
                  <img
                    src={formData.imageUrl}
                    alt="Preview"
                    className="w-12 h-12 rounded-md object-cover bg-slate-200 shrink-0"
                    onError={(e) => ((e.target as HTMLElement).style.display = 'none')}
                  />
                  <span className="text-xs text-slate-500 truncate">Image preview valid</span>
                </div>
              )}
            </div>

            {/* Description */}
            <div className="sm:col-span-2">
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Detailed Product Description
              </label>
              <textarea
                rows={3}
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                placeholder="Features, components included in the box, specifications..."
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              />
            </div>

            {/* Active Switch */}
            <div className="sm:col-span-2 flex items-center gap-2 pt-1">
              <input
                type="checkbox"
                id="is_active_toggle"
                checked={formData.is_active}
                onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                className="w-4 h-4 text-indigo-600 rounded-sm border-slate-300 focus:ring-indigo-500 cursor-pointer"
              />
              <label
                htmlFor="is_active_toggle"
                className="text-xs font-semibold text-slate-800 cursor-pointer"
              >
                Publish product immediately to Edukkit Store catalog
              </label>
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-slate-100">
            <Button type="button" variant="secondary" onClick={() => setIsModalOpen(false)}>
              Cancel
            </Button>
            <Button type="submit" isLoading={submitting}>
              {editingProduct ? 'Save Changes' : 'Create Product'}
            </Button>
          </div>
        </form>
      </Modal>

      {/* ── 2. PRODUCT DETAILS INSPECTOR MODAL ─────────────────────────────── */}
      <Modal
        isOpen={!!inspectingProduct}
        onClose={() => setInspectingProduct(null)}
        title={inspectingProduct?.name || 'Product Details'}
        subtitle="Catalog specifications and inventory status"
        maxWidth="lg"
      >
        {inspectingProduct && (
          <div className="space-y-4 text-xs">
            {inspectingProduct.images && inspectingProduct.images.length > 0 && (
              <div className="rounded-xl overflow-hidden bg-slate-900 border border-slate-200 max-h-52 flex items-center justify-center">
                <img
                  src={inspectingProduct.images[0]}
                  alt=""
                  className="w-full h-52 object-cover"
                />
              </div>
            )}

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 p-4 bg-slate-50 rounded-xl border border-slate-200">
              <div>
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Product ID</span>
                <p className="font-mono font-bold text-slate-800 mt-0.5">#{inspectingProduct.id}</p>
              </div>

              <div>
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Type</span>
                <p className="font-semibold text-slate-800 mt-0.5">
                  {inspectingProduct.type === 'diy_kit' ? 'DIY Hardware Kit' : 'Electronics Component'}
                </p>
              </div>

              <div>
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Price</span>
                <p className="font-bold text-indigo-700 text-sm mt-0.5">
                  {formatCurrency(inspectingProduct.price)}{' '}
                  {inspectingProduct.original_price && (
                    <span className="line-through text-slate-400 text-xs font-normal">
                      {formatCurrency(inspectingProduct.original_price)}
                    </span>
                  )}
                </p>
              </div>

              <div>
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Inventory Stock</span>
                <div className="mt-1">{getStockBadge(inspectingProduct.stock, inspectingProduct.is_active)}</div>
              </div>

              <div>
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Category</span>
                <p className="font-semibold text-slate-800 mt-0.5">{inspectingProduct.category || 'General'}</p>
              </div>

              <div>
                <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Store Visibility</span>
                <div className="mt-1">
                  <Badge variant={inspectingProduct.is_active ? 'success' : 'default'} size="sm">
                    {inspectingProduct.is_active ? 'Visible in Catalog' : 'Hidden from Catalog'}
                  </Badge>
                </div>
              </div>
            </div>

            {inspectingProduct.linked_course_id && (
              <div className="p-3.5 bg-emerald-50/60 rounded-xl border border-emerald-200 flex items-center justify-between">
                <div className="flex items-center gap-2.5">
                  <GraduationCap size={16} className="text-emerald-700 shrink-0" />
                  <div>
                    <p className="font-bold text-slate-800">
                      Linked Course: {getLinkedCourseTitle(inspectingProduct.linked_course_id)}
                    </p>
                    <p className="text-slate-500 text-[11px]">
                      Purchasing this kit automatically grants full access to the linked course.
                    </p>
                  </div>
                </div>
                <Link
                  to="/courses"
                  className="px-2.5 py-1 bg-emerald-600 text-white hover:bg-emerald-700 rounded-md font-semibold text-xs flex items-center gap-1 transition-colors"
                >
                  <span>View Course</span>
                  <ExternalLink size={12} />
                </Link>
              </div>
            )}

            <div>
              <span className="text-slate-400 font-bold uppercase tracking-wider text-[10px]">Description</span>
              <p className="text-slate-700 mt-1 leading-relaxed whitespace-pre-line bg-slate-50 p-3 rounded-lg border border-slate-200">
                {inspectingProduct.description || 'No description provided for this product.'}
              </p>
            </div>

            <div className="flex justify-end gap-2 pt-2">
              <Button
                variant="secondary"
                onClick={() => {
                  setInspectingProduct(null);
                  openEditModal(inspectingProduct);
                }}
                leftIcon={<Edit2 size={14} />}
              >
                Edit Product
              </Button>
              <Button variant="secondary" onClick={() => setInspectingProduct(null)}>
                Close
              </Button>
            </div>
          </div>
        )}
      </Modal>

      {/* ── 3. QUICK STOCK ADJUSTMENT MODAL ───────────────────────────────── */}
      <Modal
        isOpen={!!quickStockProduct}
        onClose={() => setQuickStockProduct(null)}
        title="Adjust Inventory Stock"
        subtitle={`Update units on hand for '${quickStockProduct?.name}'`}
        maxWidth="sm"
      >
        <form onSubmit={handleQuickStockSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Current Available Units *
            </label>
            <input
              type="number"
              min="0"
              step="1"
              value={quickStockValue}
              onChange={(e) => setQuickStockValue(Number(e.target.value))}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-lg font-bold text-slate-900 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
              required
              autoFocus
            />
            <p className="text-[11px] text-slate-400 mt-1">
              Products with 5 or fewer units will show a low stock warning.
            </p>
          </div>

          <div className="flex justify-end gap-3 pt-2">
            <Button type="button" variant="secondary" onClick={() => setQuickStockProduct(null)}>
              Cancel
            </Button>
            <Button type="submit" isLoading={quickStockSubmitting}>
              Save Stock
            </Button>
          </div>
        </form>
      </Modal>

      {/* ── 4. DELETE PRODUCT CONFIRMATION MODAL ───────────────────────────── */}
      <Modal
        isOpen={!!deletingProduct}
        onClose={() => setDeletingProduct(null)}
        title="Delete Store Product"
        subtitle="Permanent removal from catalog"
        maxWidth="md"
      >
        <div className="space-y-4 text-xs sm:text-sm text-slate-600">
          <div className="p-3.5 bg-rose-50 border border-rose-200 rounded-xl text-rose-800 text-xs flex items-start gap-2.5">
            <AlertTriangle size={18} className="text-rose-600 shrink-0 mt-0.5" />
            <div>
              <p className="font-bold">Permanent Deletion</p>
              <p className="mt-0.5">
                Are you sure you want to permanently delete <strong>"{deletingProduct?.name}"</strong> (
                <code className="font-mono">#{deletingProduct?.id}</code>)?
              </p>
            </div>
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <Button variant="secondary" onClick={() => setDeletingProduct(null)}>
              Cancel
            </Button>
            <Button variant="danger" isLoading={deleteSubmitting} onClick={handleDeleteSubmit}>
              Delete Product
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
};
