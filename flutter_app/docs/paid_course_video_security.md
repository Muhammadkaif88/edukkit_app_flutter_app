# Edukkit Paid Course Video & Offline Learning Security Architecture

## 1. Executive Summary

Edukkit's commercial paid video lessons and offline downloads are protected using platform-native Digital Rights Management (DRM), backend entitlement authorization, secure window flags, and anti-leak watermarking. 

Raw `.mp4` URLs are **never** exposed to client applications or users. The platform adheres strictly to the **Fail Closed** principle: in release builds, if DRM license acquisition or user entitlement verification fails, the player blocks playback rather than falling back to unencrypted media.

---

## 2. End-to-End Delivery Architecture

```
                      +-----------------------------+
                      | Raw Master Course Video MP4 |
                      +-----------------------------+
                                     |
                                     v
                      +-----------------------------+
                      | DRM Transcoder & Packager   |
                      | (CENC / SAMPLE-AES HLS/DASH)|
                      +-----------------------------+
                                     |
                                     v
                        +-------------------------+
                        | Encrypted CDN Segments  |
                        +-------------------------+
                                     |
     +-------------------------------+-------------------------------+
     |                                                               |
     v                                                               v
[ Android (Widevine L1/L3) ]                           [ iOS (FairPlay Streaming) ]
Media3 / ExoPlayer                                     AVPlayer / AVContentKeySession
KeySetId Offline License                               Persistable Content Key (CKC)
FLAG_SECURE Window Protection                          Screen Capture Monitoring (AirPlay/Rec)
```

---

## 3. Platform DRM Implementations

### A. Android — Google Widevine (Media3 / ExoPlayer)
1. **DASH / HLS Encryption**: Video streams are packaged with Common Encryption (CENC) using Widevine modular DRM.
2. **License Acquisition**:
   - The app receives a short-lived playback token (valid 5–15 minutes) from `/courses/{id}/lessons/{id}/playback-token`.
   - Media3 requests the license challenge from the Widevine DRM proxy with `X-Auth-Token` and session headers.
3. **Offline Playback**:
   - Widevine offline license keys (`KeySetId`) are acquired via `MediaDrmCallback.executeKeyRequest()`.
   - Encrypted segments are saved only in app-private storage (`edukkit_secure_vault/`).
   - Media is not indexed in Android MediaStore/Gallery and cannot be opened by external players (VLC, MX Player).

### B. iOS — Apple FairPlay Streaming (AVFoundation)
1. **FairPlay HLS Encryption**: Video streams are encrypted using `SAMPLE-AES` (CBCS / CBC mode).
2. **Key Session (`AVContentKeySession`)**:
   - Application requests the FairPlay Application Certificate from the backend.
   - Generates Server Playback Context (SPC) and exchanges it for a Content Key Context (CKC).
3. **Offline Playback**:
   - Generates persistable content keys stored securely in iOS Keychain/app sandbox.
   - Offline licenses follow the configured expiry duration (default: 30 days).

---

## 4. Screen Capture, Recording & Window Security

| Platform | Protection Mechanism | Behavior |
| :--- | :--- | :--- |
| **Android** | `WindowManager.LayoutParams.FLAG_SECURE` | Screenshot attempts return blank/black screens; Screen recordings show black frame; Recent apps preview is masked. |
| **iOS** | `UIScreen.capturedDidChangeNotification` & `isCaptured` | When screen recording, AirPlay, or mirroring starts, playback pauses immediately, video surface is blacked out, and a security alert is displayed. |
| **Both** | Dynamic Watermarking Layer | Non-intrusive, moving watermark (`Kaif • EDU-4821 • 18:42`) rendered over the video for forensic traceability. |

---

## 5. Backend Entitlement & API Contract

### Required Endpoints:
```http
POST /courses/{courseId}/lessons/{lessonId}/playback-token
Headers: Authorization: Bearer <UserJWT>
Request Body:
{
  "user_id": "string",
  "device_id": "string",
  "platform": "android" | "ios" | "web"
}
Response 200 OK:
{
  "success": true,
  "entitlement": {
    "user_id": "kaif_user_4821",
    "course_id": "course_robotics_01",
    "lesson_id": "lesson_1",
    "is_authorized": true,
    "is_free_preview": false,
    "playback_token": "eyJhbGciOi...",
    "token_expires_at": "2026-08-14T20:45:00Z",
    "stream_manifest_url": "https://cdn.edukkit.com/hls/robotics/lesson1/master.m3u8",
    "license_server_url": "https://drm.edukkit.com/widevine/license",
    "license_headers": {
      "X-Custom-Auth": "token_..."
    },
    "drm_scheme": "widevine",
    "max_offline_days": 30
  }
}
```

```http
POST /courses/{courseId}/lessons/{lessonId}/offline-license
Request Body:
{
  "user_id": "string",
  "device_id": "string",
  "platform": "android" | "ios"
}
Response 200 OK:
{
  "success": true,
  "license_id": "lic_98412",
  "key_set_id": "keyset_enc_base64...",
  "offline_days": 30
}
```

```http
POST /devices/authorize
Request Body:
{
  "user_id": "string",
  "device_id": "string",
  "platform": "android" | "ios"
}
Response 200 OK:
{
  "authorized": true,
  "active_devices_count": 1,
  "max_allowed_devices": 2
}
```

---

## 6. Offline Learning & Expiry Policy

- **Default Offline Validity**: 30 days.
- **License Revalidation**: When expired, the app prompts: *"Offline access has expired. Connect to the internet to renew license."* Connecting to the internet contacts the entitlement backend to renew the offline DRM license without needing to re-download media segments.
- **Revocation**: If a user's course access is revoked or refunded by admin, the next online check invalidates both the streaming authorization and the offline KeySetId.
- **Deletion**: When a user taps *"Remove Download"*, the encrypted media files in `edukkit_secure_vault` are deleted and the associated offline DRM license is released.

---

## 7. Development vs Production Mode

- **Debug Mode (`kDebugMode`)**:
  - Allows local sandbox mock DRM authorization and local encrypted chunk simulation when backend DRM license servers are in staging/development.
- **Release Mode (`kReleaseMode`)**:
  - **Fails closed**. If DRM license endpoints or credentials are not supplied, paid playback fails with `SecurityState.licenseError`. Unencrypted playback of paid lessons is strictly forbidden.

---

## 8. Deployment Checklist

- [x] Android `FLAG_SECURE` window management in `MainActivity.kt`.
- [x] iOS `UIScreen.capturedDidChangeNotification` capture protection in `AppDelegate.swift`.
- [x] `DrmLicenseService` with backend entitlement verification.
- [x] `OfflineLearningManager` with app-private encrypted storage.
- [x] `OfflineLearningScreen` with storage management and license status.
- [x] `DynamicWatermarkLayer` with periodic repositioning.
- [x] No raw MP4 URLs exposed in UI or file systems.
- [x] `flutter analyze` passes with 0 errors.
- [ ] Connect production Widevine & FairPlay license server URLs in `DrmLicenseService.configure()`.
