from sqlalchemy import Column, Integer, String, Float, DateTime
from sqlalchemy.sql import func
from ..database import Base

class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String)
    price = Column(Float, default=0.0)
    stock = Column(Integer, default=0)
    images = Column(String, nullable=True) # JSON array as string
    category = Column(String, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
