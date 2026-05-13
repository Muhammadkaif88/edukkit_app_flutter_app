import os

base_dir = "lib"

dirs = [
    "core/theme",
    "core/constants",
    "core/utils",
    "core/config",
    "models",
    "services",
    "providers",
    "screens/auth",
    "screens/home",
    "screens/courses",
    "screens/learning",
    "screens/downloads",
    "screens/store",
    "screens/cart",
    "screens/profile",
    "screens/ai_chat",
    "screens/notifications",
    "widgets"
]

files = {
    "models/user_model.dart": "",
    "models/course_model.dart": "",
    "models/lesson_model.dart": "",
    "models/product_model.dart": "",
    "models/order_model.dart": "",
    "services/api_service.dart": "",
    "services/auth_service.dart": "",
    "services/razorpay_service.dart": "",
    "services/video_service.dart": "",
    "services/ai_chat_service.dart": "",
    "services/notification_service.dart": "",
    "providers/auth_provider.dart": "",
    "providers/course_provider.dart": "",
    "providers/cart_provider.dart": "",
    "providers/product_provider.dart": "",
    "providers/download_provider.dart": "",
    "widgets/course_card.dart": "",
    "widgets/product_card.dart": "",
    "widgets/banner_slider.dart": "",
    "widgets/video_player.dart": "",
    "widgets/loading_widgets.dart": ""
}

os.makedirs(base_dir, exist_ok=True)

for d in dirs:
    os.makedirs(os.path.join(base_dir, d), exist_ok=True)

for f, content in files.items():
    path = os.path.join(base_dir, f)
    with open(path, "w") as file:
        file.write(content)
