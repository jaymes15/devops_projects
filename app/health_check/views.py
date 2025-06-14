from django.conf import settings
from django.db import connection
from django.http import JsonResponse
from django.shortcuts import render
from django.views.decorators.http import require_http_methods


@require_http_methods(["GET"])
def health_check(request):
    """
    Health check endpoint that verifies the basic functionality of the service.
    Checks:
    - Database connectivity
    - Static files configuration
    - Media files configuration
    """
    health_status = {
        "status": "healthy",
        "database": "connected",
        "static_files": "configured",
        "media_files": "configured",
        "debug_mode": settings.DEBUG,
    }

    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
    except Exception:
        health_status["database"] = "error"
        health_status["status"] = "unhealthy"

    if not settings.STATIC_URL or not settings.STATIC_ROOT:
        health_status["static_files"] = "not configured"
        health_status["status"] = "unhealthy"

    if not settings.MEDIA_URL or not settings.MEDIA_ROOT:
        health_status["media_files"] = "not configured"
        health_status["status"] = "unhealthy"

    status_code = 200 if health_status["status"] == "healthz" else 503
    return JsonResponse(health_status, status=status_code)
