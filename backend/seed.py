from app.database import SessionLocal, engine, Base
from app.models.course import Course
from app.models.product import Product
from app.models.user import User

# Ensure tables are created
Base.metadata.create_all(bind=engine)

def seed_db():
    db = SessionLocal()
    
    # Check if we already seeded
    if db.query(Course).first():
        print("Database already seeded!")
        db.close()
        return

    # Seed Courses
    courses = [
        Course(title="Junior Innovator", description="Lesson One: Hello World", category="Robotics", price=0.0, is_published=True),
        Course(title="Workshop Kit", description="Build your first circuit", category="Electronics", price=49.99, is_published=True),
        Course(title="Python for Hardware", description="Mastering Python on microcontrollers", category="Software", price=29.99, is_published=True)
    ]
    
    # Seed Products
    products = [
        Product(name="Arduino Starter Kit", description="Complete kit with Uno R3", price=34.99, stock=50, category="Kits"),
        Product(name="Drone Assembly Kit", description="Build your own quadcopter", price=120.00, stock=10, category="Drones"),
        Product(name="Smart Car Chassis", description="2WD robot car platform", price=25.50, stock=100, category="Robotics")
    ]
    
    db.add_all(courses)
    db.add_all(products)
    db.commit()
    print("Successfully seeded database!")
    db.close()

if __name__ == "__main__":
    seed_db()
