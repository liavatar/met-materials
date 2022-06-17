

import MetalKit

struct GBufferRenderPass: RenderPass {
  let label = "G-buffer Render Pass"
  var descriptor: MTLRenderPassDescriptor?

  var pipelineState: MTLRenderPipelineState
  let depthStencilState: MTLDepthStencilState?
  weak var shadowTexture: MTLTexture?
  var albedoTexture: MTLTexture?
  var normalTexture: MTLTexture?
  var positionTexture: MTLTexture?
  var depthTexture: MTLTexture?


  init(view: MTKView) {
    pipelineState = PipelineStates.createGBufferPSO(
      colorPixelFormat: view.colorPixelFormat)
    depthStencilState = Self.buildDepthStencilState()
    
    descriptor = MTLRenderPassDescriptor()
  }

  mutating func resize(view: MTKView, size: CGSize) {
    albedoTexture = Self.makeTexture(
      size: size,
      pixelFormat: .bgra8Unorm,
      label: "Albedo Texture")
    normalTexture = Self.makeTexture(
      size: size,
      pixelFormat: .rgba16Float,
      label: "Normal Texture")
    positionTexture = Self.makeTexture(
      size: size,
      pixelFormat: .rgba16Float,
      label: "Position Texture")
    depthTexture = Self.makeTexture(
      size: size,
      pixelFormat: .depth32Float,
      label: "Depth Texture")

  }

  func draw(
    commandBuffer: MTLCommandBuffer,
    scene: GameScene,
    uniforms: Uniforms,
    params: Params
  ) {
    
    let textures = [
      albedoTexture,
      normalTexture,
      positionTexture
    ]
    for (index, texture) in textures.enumerated() {
      let attachment =
        descriptor?.colorAttachments[RenderTargetAlbedo.index + index]
      attachment?.texture = texture
      attachment?.loadAction = .clear
      attachment?.storeAction = .store
      attachment?.clearColor =
        MTLClearColor(red: 0.73, green: 0.92, blue: 1, alpha: 1)
    }
    descriptor?.depthAttachment.texture = depthTexture
    descriptor?.depthAttachment.storeAction = .dontCare  // we don't need the depth attachment after this render pass

    guard let descriptor = descriptor,
    let renderEncoder =
      commandBuffer.makeRenderCommandEncoder(
        descriptor: descriptor) else {
      return
    }
    renderEncoder.label = label
    renderEncoder.setDepthStencilState(depthStencilState)
    renderEncoder.setRenderPipelineState(pipelineState)

    // gBuffer pass doesn't use light buffer
//    renderEncoder.setFragmentBuffer(
//      scene.lighting.lightsBuffer,
//      offset: 0,
//      index: LightBuffer.index)
    renderEncoder.setFragmentTexture(shadowTexture, index: ShadowTexture.index)
    for model in scene.models {
      model.render(
        encoder: renderEncoder,
        uniforms: uniforms,
        params: params)
    }
    renderEncoder.endEncoding()
  }
}
