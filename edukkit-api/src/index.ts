import { Hono } from 'hono';
import { cors } from 'hono/cors';

export interface Env {
  edukkit_db: D1Database;
}

const app = new Hono<{ Bindings: Env }>();

app.use('/*', cors({
  origin: '*',
  allowHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept'],
  allowMethods: ['POST', 'GET', 'OPTIONS', 'PUT', 'DELETE'],
  maxAge: 600,
}));

// 1. Health Check
app.get('/', (c) => {
  return c.json({ status: 'ok', message: 'Edukkit API is running!' });
});

// 2. Setup Database (Run this to create/update tables)
app.post('/setup', async (c) => {
  try {
    // Users Table
    await c.env.edukkit_db.prepare(`
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY, 
        name TEXT NOT NULL, 
        email TEXT UNIQUE NOT NULL, 
        role TEXT DEFAULT 'student', 
        photo_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `).run();

    // Courses Table
    await c.env.edukkit_db.prepare(`
      CREATE TABLE IF NOT EXISTS courses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        instructor TEXT,
        price REAL DEFAULT 0,
        thumbnail_url TEXT,
        category TEXT,
        is_published BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `).run();

    // Lessons Table
    await c.env.edukkit_db.prepare(`
      CREATE TABLE IF NOT EXISTS lessons (
        id TEXT PRIMARY KEY,
        course_id TEXT,
        title TEXT NOT NULL,
        video_url TEXT,
        duration TEXT,
        order_index INTEGER,
        FOREIGN KEY(course_id) REFERENCES courses(id)
      );
    `).run();

    // Products (DIY Kits) Table
    await c.env.edukkit_db.prepare(`
      CREATE TABLE IF NOT EXISTS products (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        price REAL DEFAULT 0,
        image_url TEXT,
        stock INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `).run();

    // Notifications Table
    await c.env.edukkit_db.prepare(`
      CREATE TABLE IF NOT EXISTS notifications (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        title TEXT NOT NULL,
        description TEXT,
        type TEXT,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `).run();

    // Banners Table
    await c.env.edukkit_db.prepare(`
      CREATE TABLE IF NOT EXISTS banners (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT,
        button_text TEXT,
        image_url TEXT,
        bg_color TEXT,
        action_url TEXT
      );
    `).run();

    return c.json({ success: true, message: 'All tables initialized!' });
  } catch (e: any) {
    return c.json({ success: false, error: e.message }, 500);
  }
});

// --- USER MANAGEMENT ---

app.post('/sync-user', async (c) => {
  const body = await c.req.json();
  const { id, name, email, photo_url } = body;
  
  if (!id) return c.json({ error: 'Missing user ID' }, 400);

  try {
    const existing = await c.env.edukkit_db.prepare('SELECT * FROM users WHERE id = ?').bind(id).first();
    
    if (existing) {
      // Update existing user (in case photo or name changed)
      await c.env.edukkit_db
        .prepare('UPDATE users SET name = ?, photo_url = ? WHERE id = ?')
        .bind(name, photo_url, id)
        .run();
      return c.json({ success: true, user: { ...existing, name, photo_url } });
    } else {
      const role = body.role || 'student';
      await c.env.edukkit_db
        .prepare('INSERT INTO users (id, name, email, role, photo_url) VALUES (?, ?, ?, ?, ?)')
        .bind(id, name, email, role, photo_url)
        .run();
      return c.json({ success: true, user: { id, name, email, role, photo_url } });
    }
  } catch (e: any) {
    return c.json({ success: false, error: e.message }, 500);
  }
});

app.get('/users', async (c) => {
  try {
    const { results } = await c.env.edukkit_db.prepare('SELECT * FROM users ORDER BY created_at DESC').all();
    return c.json({ users: results });
  } catch (e: any) {
    return c.json({ success: false, error: e.message }, 500);
  }
});

app.post('/users/role', async (c) => {
  const body = await c.req.json();
  const { id, role } = body;

  if (!id || !role) return c.json({ error: 'Missing user ID or role' }, 400);

  try {
    await c.env.edukkit_db.prepare('UPDATE users SET role = ? WHERE id = ?').bind(role, id).run();
    return c.json({ success: true });
  } catch (e: any) {
    return c.json({ success: false, error: e.message }, 500);
  }
});


// --- COURSES ---

app.get('/courses', async (c) => {
  const { results } = await c.env.edukkit_db.prepare('SELECT * FROM courses WHERE is_published = 1').all();
  return c.json({ courses: results });
});

app.post('/courses', async (c) => {
  const body = await c.req.json();
  const { title, description, instructor, price, thumbnail_url, category } = body;
  const id = crypto.randomUUID();
  
  try {
    await c.env.edukkit_db
      .prepare('INSERT INTO courses (id, title, description, instructor, price, thumbnail_url, category, is_published) VALUES (?, ?, ?, ?, ?, ?, ?, 1)')
      .bind(id, title, description, instructor, price, thumbnail_url, category)
      .run();
    return c.json({ success: true, id });
  } catch (e: any) {
    return c.json({ success: false, error: e.message }, 500);
  }
});

app.get('/courses/:id/lessons', async (c) => {
  const courseId = c.req.param('id');
  const { results } = await c.env.edukkit_db
    .prepare('SELECT * FROM lessons WHERE course_id = ? ORDER BY order_index ASC')
    .bind(courseId)
    .all();
  return c.json({ lessons: results });
});

app.post('/lessons', async (c) => {
  const body = await c.req.json();
  const { course_id, title, video_url, duration, order_index } = body;
  const id = crypto.randomUUID();
  
  try {
    await c.env.edukkit_db
      .prepare('INSERT INTO lessons (id, course_id, title, video_url, duration, order_index) VALUES (?, ?, ?, ?, ?, ?)')
      .bind(id, course_id, title, video_url, duration, order_index)
      .run();
    return c.json({ success: true, id });
  } catch (e: any) {
    return c.json({ success: false, error: e.message }, 500);
  }
});

// --- PRODUCTS (DIY KITS) ---

app.get('/products', async (c) => {
  const { results } = await c.env.edukkit_db.prepare('SELECT * FROM products').all();
  return c.json({ products: results });
});

app.post('/products', async (c) => {
  const body = await c.req.json();
  const { title, description, price, image_url, stock } = body;
  const id = crypto.randomUUID();
  
  try {
    await c.env.edukkit_db
      .prepare('INSERT INTO products (id, title, description, price, image_url, stock) VALUES (?, ?, ?, ?, ?, ?)')
      .bind(id, title, description, price, image_url, stock)
      .run();
    return c.json({ success: true, id });
  } catch (e: any) {
    return c.json({ success: false, error: e.message }, 500);
  }
});

// --- NOTIFICATIONS ---

app.get('/notifications/:userId', async (c) => {
  const userId = c.req.param('userId');
  const { results } = await c.env.edukkit_db
    .prepare('SELECT * FROM notifications WHERE user_id = ? OR user_id IS NULL ORDER BY created_at DESC')
    .bind(userId)
    .all();
  return c.json({ notifications: results });
});

app.post('/notifications/read', async (c) => {
  const { id } = await c.req.json();
  await c.env.edukkit_db.prepare('UPDATE notifications SET is_read = 1 WHERE id = ?').bind(id).run();
  return c.json({ success: true });
});

// --- BANNERS ---

app.get('/banners', async (c) => {
  const { results } = await c.env.edukkit_db.prepare('SELECT * FROM banners').all();
  return c.json({ banners: results });
});

app.post('/banners', async (c) => {
  const body = await c.req.json();
  const { 
    title, 
    subtitle = '', 
    button_text = '', 
    image_url = '', 
    bg_color = '', 
    action_url = '' 
  } = body;
  const id = crypto.randomUUID();
  
  try {
    await c.env.edukkit_db
      .prepare('INSERT INTO banners (id, title, subtitle, button_text, image_url, bg_color, action_url) VALUES (?, ?, ?, ?, ?, ?, ?)')
      .bind(id, title, subtitle, button_text, image_url, bg_color, action_url)
      .run();
    return c.json({ success: true, id });
  } catch (e: any) {
    return c.json({ success: false, error: e.message }, 500);
  }
});
// --- SEARCH ---

app.get('/search', async (c) => {
  const query = c.req.query('q');
  if (!query) return c.json({ courses: [], products: [] });

  const searchPattern = `%${query}%`;

  const coursesPromise = c.env.edukkit_db
    .prepare('SELECT * FROM courses WHERE title LIKE ? OR description LIKE ?')
    .bind(searchPattern, searchPattern)
    .all();

  const productsPromise = c.env.edukkit_db
    .prepare('SELECT * FROM products WHERE title LIKE ? OR description LIKE ?')
    .bind(searchPattern, searchPattern)
    .all();

  const [courses, products] = await Promise.all([coursesPromise, productsPromise]);

  return c.json({
    courses: courses.results,
    products: products.results
  });
});

export default app;
