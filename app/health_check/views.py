from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
from django.db import connection
from django.conf import settings

import gc

big_data_holder = []

@require_http_methods(["GET"])
def health_check(request):
    """
    Modified health check that simulates memory load.
    """

    global big_data_holder
    big_data_holder.extend([bytearray(10 * 1024 * 1024)] * 5)  # ~50MB per request

    health_status = {
        "status": "healthy",
        "database": "connected",
        "static_files": "configured",
        "media_files": "configured",
        "debug_mode": settings.DEBUG,
        "memory_chunks": len(big_data_holder)
    }

    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
    except Exception as e:
        health_status["database"] = "error"
        health_status["status"] = "unhealthy"
    
    if not settings.STATIC_URL or not settings.STATIC_ROOT:
        health_status["static_files"] = "not configured"
        health_status["status"] = "unhealthy"
    
    if not settings.MEDIA_URL or not settings.MEDIA_ROOT:
        health_status["media_files"] = "not configured"
        health_status["status"] = "unhealthy"

    status_code = 200 if health_status["status"] == "healthy" else 503
    return JsonResponse(health_status, status=status_code)
