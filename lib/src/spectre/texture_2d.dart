part of spectre;

/*

  Copyright (C) 2012 John McCutchan <john@johnmccutchan.com>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

*/

/// Texture2D defines the storage for a 2D texture including Mipmaps
/// Create using [Device.createTexture2D]
/// Set using [immediateContext.setTextures]
/// NOTE: Unlike OpenGL, Spectre textures do not describe how they are sampled
class Texture2D extends Texture {
  bool _loadError = false;

  /** Did an error occur when loading from a URL? */
  bool get loadError => _loadError;

  Texture2D(String name, GraphicsDevice device) : super(name, device) {
    _target = WebGLRenderingContext.TEXTURE_2D;
    _target_param = WebGLRenderingContext.TEXTURE_BINDING_2D;
  }

  void _createDeviceState() {
    super._createDeviceState();
  }

  void _configDeviceState(Map props) {
    super._configDeviceState(props);

    if (props != null && props['pixels'] != null) {
      var pixels = props['pixels'];
      uploadElement(pixels);
    } else {
      if (props != null) {
        _width = props['width'] != null ? props['width'] : _width;
        _height = props['height'] != null ? props['height'] : _height;
        _textureFormat = props['textureFormat'] != null ?
            props['textureFormat'] : _textureFormat;
      }
      // TODO(johnmccutchan): Kill this hack.
      // TODO(johnmccutchan): Support texture properties.
      device.gl.pixelStorei(WebGLRenderingContext.UNPACK_FLIP_Y_WEBGL, 1);
      uploadPixelArray(width, height, null);
    }
  }

  void _destroyDeviceState() {
    super._destroyDeviceState();
  }

  void _uploadPixelArray(int width, int height, dynamic array,
                         int pixelFormat, int pixelType) {
    device.gl.texImage2D(_target, 0, _textureFormat, width, height,
                         0, pixelFormat, pixelType, array);
  }

  /** Replace texture contents with data stored in [array].
   * If [array] is null, space will be allocated on the GPU
   */
  void uploadPixelArray(int width, int height, dynamic array,
                        {pixelFormat: Texture.FormatRGBA,
                         pixelType: Texture.PixelTypeU8}) {
    WebGLTexture oldBind = device.gl.getParameter(_target_param);
    device.gl.bindTexture(_target, _buffer);
    _width = width;
    _height = height;
    _uploadPixelArray(width, height, array, pixelFormat, pixelType);
    device.gl.bindTexture(_target, oldBind);
  }

  void _uploadElement(dynamic element, int pixelFormat, int pixelType) {
    device.gl.texImage2D(_target, 0, _textureFormat,
                         pixelFormat, pixelType, element);
  }

  /** Replace texture contents with image data from [element].
   * Supported for [ImageElement], [VideoElement], and [CanvasElement].
   *
   * The image data will be converted to [pixelFormat] and [pixelType] before
   * being uploaded to the GPU.
   */
  void uploadElement(dynamic element,
                     {pixelFormat: Texture.FormatRGBA,
                         pixelType: Texture.PixelTypeU8}) {
    if (element is ImageElement) {
      _width = element.naturalWidth;
      _height = element.naturalHeight;
    } else if (element is CanvasElement) {
      _width = element.width;
      _height = element.height;
    } else if (element is VideoElement) {
      _width = element.width;
      _height = element.height;
    } else {
      throw new ArgumentError('element is not supported.');
    }
    WebGLTexture oldBind = device.gl.getParameter(_target_param);
    device.gl.bindTexture(_target, _buffer);
    _uploadElement(element, pixelFormat, pixelType);
    device.gl.bindTexture(_target, oldBind);
  }

  /** Replace texture contents with data fetched from [url].
   * If an error occurs while fetching the image, loadError will be true.
   */
  Future<Texture2D> uploadFromURL(Sting url,
                                  {pixelFormat: Texture.FormatRGBA,
                                   pixelType: Texture.PixelTypeU8}) {
    ImageElement element = new ImageElement();
    Completer<Texture2D> completer = new Completer<Texture2D>();
    element.on.error.add((event) {
      _loadError = true;
      completer.complete(this);
    });
    element.on.load.add((event) {
      uploadElement(element, pixelFormat, pixelType);
      completer.complete(this);
    });
    // Initiate load.
    _loadError = false;
    element.src = url;
    return completer.future;
  }

  void _generateMipmap() {
    device.gl.generateMipmap(_target);
  }

  /** Generate Mipmap data for texture. This must be done before the texture
   * can be used for rendering.
   */
  void generateMipmap() {
    WebGLTexture oldBind = device.gl.getParameter(_target_param);
    device.gl.bindTexture(_target, _buffer);
    _generateMipmap();
    device.gl.bindTexture(_target, oldBind);
  }
}