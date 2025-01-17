
#include <metal_stdlib>
using namespace metal;

struct Ray {
  float3 origin;
  float3 direction;
};

struct Sphere {
  float3 center;
  float radius;
};

struct Plane {
  float yCoord;
};

struct Light {
  float3 position;
};

float distToSphere(Ray ray, Sphere s) {
  return length(ray.origin - s.center) - s.radius;
}

float distToPlane(Ray ray, Plane plane) {
  return ray.origin.y - plane.yCoord;
}

float differenceOp(float d0, float d1) {
  return max(d0, -d1);
}

float unionOp(float d0, float d1) {
  return min(d0, d1);
}

float distToScene(Ray r) {
  // 1
  Plane p = Plane{0.0};
  float d2p = distToPlane(r, p);
  // 2
  Sphere s1 = Sphere{float3(2.0), 2.0};
  Sphere s2 = Sphere{float3(0.0, 4.0, 0.0), 4.0};
  Sphere s3 = Sphere{float3(0.0, 4.0, 0.0), 3.9};
  // 3
  Ray repeatRay = r;
  repeatRay.origin = fract(r.origin / 4.0) * 4.0;
  // 4
  float d2s1 = distToSphere(repeatRay, s1);
  float d2s2 = distToSphere(r, s2);
  float d2s3 = distToSphere(r, s3);
  // 5
  float dist = differenceOp(d2s2, d2s3);
  dist = differenceOp(dist, d2s1);
  dist = unionOp(d2p, dist);
  return dist;
}

float3 getNormal(Ray ray) {
  float2 eps = float2(0.001, 0.0);
  float3 n = float3(
    distToScene(Ray{ray.origin + eps.xyy, ray.direction}) -
    distToScene(Ray{ray.origin - eps.xyy, ray.direction}),
    distToScene(Ray{ray.origin + eps.yxy, ray.direction}) -
    distToScene(Ray{ray.origin - eps.yxy, ray.direction}),
    distToScene(Ray{ray.origin + eps.yyx, ray.direction}) -
    distToScene(Ray{ray.origin - eps.yyx, ray.direction}));
  return normalize(n);
}

float lighting(Ray ray, float3 normal, Light light) {
  // 1
  float3 lightRay = normalize(light.position - ray.origin);
  // 2
  float diffuse = max(0.0, dot(normal, lightRay));
  // 3
  float3 reflectedRay = reflect(ray.direction, normal);
  float specular = max(0.0, dot(reflectedRay, lightRay));
  // 4
  specular = pow(specular, 200.0);
  return diffuse + specular;
}

// 1
float shadow(Ray ray, float k, Light l) {
  float3 lightDir = l.position - ray.origin;
  float lightDist = length(lightDir);
  lightDir = normalize(lightDir);
  // 2
  float light = 1.0;
  float eps = 0.1;
  // 3
  float distAlongRay = eps * 2.0;
  for (int i=0; i<100; i++) {
    Ray lightRay = Ray{ray.origin + lightDir * distAlongRay,
                       lightDir};
    float dist = distToScene(lightRay);
    // 4
    light = min(light, 1.0 - (eps - dist) / eps);
    // 5
    distAlongRay += dist * 0.5;
    eps += dist * k;
    // 6
    if (distAlongRay > lightDist) { break; }
  }
  return max(light, 0.0);
}

kernel void compute(texture2d<float, access::write> output [[texture(0)]],
                    constant float &time [[buffer(0)]],
                    uint2 gid [[thread_position_in_grid]]) {
  int width = output.get_width();
  int height = output.get_height();
  float2 uv = float2(gid) / float2(width, height);
  uv = uv * 2.0 - 1.0;
  uv.y = -uv.y;
  float3 col = float3(0.0);

  Ray ray = Ray{float3(0., 4., -12), normalize(float3(uv, 1.))};

  bool hit = false;
  for (int i = 0; i < 200; i++) {
    float dist = distToScene(ray);
    if (dist < 0.001) {
      hit = true;
      break;
    }
    ray.origin += ray.direction * dist;
  }
  col = float3(1.0);
  if (!hit) {
    col = float3(0.8, 0.5, 0.5);
  } else {
    float3 n = getNormal(ray);
    Light light = Light{float3(sin(time) * 10.0, 5.0,
                               cos(time) * 10.0)};
    float l = lighting(ray, n, light);
    float s = shadow(ray, 0.3, light);
    col = col * l * s;
  }
  Light light2 = Light{float3(0.0, 5.0, -15.0)};
  float3 lightRay = normalize(light2.position - ray.origin);
  float fl = max(0.0, dot(getNormal(ray), lightRay) / 2.0);
  col = col + fl;
  output.write(float4(col, 1.0), gid);
}
