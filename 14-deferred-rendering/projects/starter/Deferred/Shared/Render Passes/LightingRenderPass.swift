import MetalKit

struct LightingRenderPass: RenderPass {
  let label = "Lighting Render Pass"
  var descriptor: MTLRenderPassDescriptor?
  var sunLightPSO: MTLRenderPipelineState
  var pointLightPSO: MTLRenderPipelineState
  let depthStencilState: MTLDepthStencilState?
  weak var albedoTexture: MTLTexture?
  weak var normalTexture: MTLTexture?
  weak var positionTexture: MTLTexture?
  var icosphere = Model(name: "icosphere.obj")


  init(view: MTKView) {
    sunLightPSO = PipelineStates.createSunLightPSO(colorPixelFormat: view.colorPixelFormat)
    pointLightPSO = PipelineStates.createPointLightPSO(colorPixelFormat: view.colorPixelFormat)

    depthStencilState = Self.buildDepthStencilState()
  }

  // overwrite the default one in RenderPass.swift in order to disable the DepthWrite
  static func buildDepthStencilState() -> MTLDepthStencilState? {
    let descriptor = MTLDepthStencilDescriptor()
    descriptor.isDepthWriteEnabled = false
    return Renderer.device.makeDepthStencilState(descriptor: descriptor)
  }

  func resize(view: MTKView, size: CGSize) {}

  func draw(
    commandBuffer: MTLCommandBuffer,
    scene: GameScene,
    uniforms: Uniforms,
    params: Params
  ) {
    guard let descriptor = descriptor,
      let renderEncoder =
        commandBuffer.makeRenderCommandEncoder(
        descriptor: descriptor) else {
          return
    }
    renderEncoder.label = label
    renderEncoder.setDepthStencilState(depthStencilState)
    var uniforms = uniforms
    renderEncoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<Uniforms>.stride,
      index: UniformsBuffer.index)
    
    renderEncoder.setFragmentTexture(
      albedoTexture,
      index: BaseColor.index)
    renderEncoder.setFragmentTexture(
      normalTexture,
      index: NormalTexture.index)
    renderEncoder.setFragmentTexture(
      positionTexture, index:
      NormalTexture.index + 1)

    drawSunLight(
      renderEncoder: renderEncoder,
      scene: scene,
      params: params)
    
    drawPointLight(
      renderEncoder: renderEncoder,
      scene: scene,
      params: params)

    renderEncoder.endEncoding()

  }
  
  func drawSunLight(
    renderEncoder: MTLRenderCommandEncoder,
    scene: GameScene,
    params: Params
  ) {
    renderEncoder.pushDebugGroup("Sun Light")
    renderEncoder.setRenderPipelineState(sunLightPSO)
    var params = params
    params.lightCount = UInt32(scene.lighting.sunlights.count)
    renderEncoder.setFragmentBytes(
      &params,
      length: MemoryLayout<Params>.stride,
      index: ParamsBuffer.index)
    renderEncoder.setFragmentBuffer(
      scene.lighting.sunBuffer,
      offset: 0,
      index: LightBuffer.index)
    renderEncoder.drawPrimitives(
      type: .triangle,
      vertexStart: 0,
      vertexCount: 6)
    renderEncoder.popDebugGroup()
  }
  
  func drawPointLight(
    renderEncoder: MTLRenderCommandEncoder,
    scene: GameScene,
    params: Params
  ) {
    renderEncoder.pushDebugGroup("Point lights")
    
    renderEncoder.setRenderPipelineState(pointLightPSO)
    renderEncoder.setVertexBuffer(
      scene.lighting.pointBuffer,
      offset: 0,
      index: LightBuffer.index)
    renderEncoder.setFragmentBuffer(
      scene.lighting.pointBuffer,
      offset: 0,
      index: LightBuffer.index)
    
    guard let mesh = icosphere.meshes.first,
      let submesh = mesh.submeshes.first else { return }
    for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
      renderEncoder.setVertexBuffer(
        vertexBuffer,
        offset: 0,
        index: index)
    }
    renderEncoder.drawIndexedPrimitives(
      type: .triangle,
      indexCount: submesh.indexCount,
      indexType: submesh.indexType,
      indexBuffer: submesh.indexBuffer,
      indexBufferOffset: submesh.indexBufferOffset,
      instanceCount: scene.lighting.pointLights.count)
    
    renderEncoder.popDebugGroup()

  }

}

