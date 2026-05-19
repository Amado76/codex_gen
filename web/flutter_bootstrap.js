// Custom Flutter Web bootstrap.
// Forces CanvasKit renderer for better image quality on production hosts.

{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  config: {
    renderer: "canvaskit",
    canvasKitVariant: "full",
    // Keep CanvasKit assets local (served from /canvaskit/).
    canvasKitBaseUrl: "canvaskit/",
  },
});
