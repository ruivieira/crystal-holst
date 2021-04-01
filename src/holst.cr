require "json"
require "base64"

module Holst
  # Represents a kernel spec, typically having a `display_name`, `language` and `name`
  class KernelSpec
    include JSON::Serializable

    # The kernel's display name for the UI
    @[JSON::Field(key: "display_name")]
    property display_name : String?

    # The kernel's language runtime
    @[JSON::Field(key: "language")]
    property language : String?

    # The kernel's name
    @[JSON::Field(key: "name")]
    property name : String?
  end

  class JupyterMetadata
    include JSON::Serializable

    @[JSON::Field(key: "kernelspec")]
    property kernelspec : KernelSpec
  end

  # Cell type definition.
  # Currently only two types exist, Markdown or code.
  enum CellType
    CODE
    MARKDOWN
  end

  class JupyterCell
    include JSON::Serializable

    @[JSON::Field(key: "cell_type")]
    property cell_type : String

    @[JSON::Field(key: "id")]
    property id : String?

    @[JSON::Field(key: "metadata")]
    property metadata : JSON::Any

    @[JSON::Field(key: "source")]
    property source : Array(String) | Nil

    @[JSON::Field(key: "execution_count")]
    property execution_count : Int32?

    @[JSON::Field(key: "outputs")]
    property outputs : Array(Hash(String, JSON::Any)) | Nil

    # Returns the cell's type as a `CellType`, either Markdown or code
    #
    # Example:
    # ```
    # notebook.cells[0].type # => Holst::CellType::MARKDOWN
    # notebook.cells[1].type # => Holst::CellType::CODE
    # ```
    def type : CellType
      if @cell_type == "markdown"
        return CellType::MARKDOWN
      else
        return CellType::CODE
      end
    end

    def is_markdown? : Bool
      return type == CellType::MARKDOWN
    end

    def is_code? : Bool
      return type == CellType::CODE
    end

    def has_data? : Bool
      if is_code?
        if outputs = @outputs
          data = outputs.find { |output|
            output.has_key?("data")
          }
          return !data.nil?
        else
          return false
        end
      else
        return false
      end
    end

    def has_image? : Bool
      if has_data?
        if outputs = @outputs
          data = outputs.find { |output| output.has_key?("data") }
          return !data.nil?
        else
          return false
        end
      else
        return false
      end
    end

    def get_image : Bytes | Nil
      if has_image?
        data = @outputs["data"]
        return Base64.decode(data["image/png"].as_s)
      end
      return nil
    end
  end

  class JupyterSource
    include JSON::Serializable

    @[JSON::Field(key: "cells")]
    property cells : Array(JupyterCell)

    # The Jupyter notebook's metadata as a `JupyterMetadata`
    @[JSON::Field(key: "metadata")]
    property metadata : JupyterMetadata
  end

  # Representation of a Jupyter notebook
  class JupyterFile
    getter content : JupyterSource

    def initialize(@file_path : String, @image_prefix = "image", @image_dest = "images")
      @content = JupyterSource.from_json(File.read(@file_path))
    end

    # Get all images contained in this notebook.
    # Images are returned as an array of `Bytes`.
    #
    # Example:
    # ```
    # i = 1
    # notebook.images.each { |img|
    #   File.write("image-#{i}.png", img)
    #   i += 1
    # }
    # ```
    def images : Array(Bytes)
      _images = [] of Bytes
      @content.cells.each { |cell|
        if cell.is_code?
          outputs = cell.outputs
          if outputs
            data_output = outputs.find { |output| output.has_key?("data") }
            if data_output && data_output.has_key?("data")
              data = data_output["data"].as_h
              if data && data.has_key?("image/png")
                _images << Base64.decode(data["image/png"].as_s)
              end
            end
          end
        end
      }
      return _images
    end

    # Get the notebook's metadata as a `JupyterMetadata`
    def metadata : JupyterMetadata
      return @content.metadata
    end

    # Returns all the cells in this notebook as an `Array(JupyterCell)`.
    # Example:
    # ```
    # notebook.cells.size # => 28
    # notebook.cells.each { |cell| puts(cell) }
    # ```
    def cells : Array(JupyterCell)
      return @content.cells
    end

    def export_images
      image_counter = 1
      if !Dir.exists?(@image_dest)
        Dir.mkdir(@image_dest)
      end
      images.each { |image|
        File.write("#{@image_dest}/#{@image_prefix}-#{image_counter}.png", image)
        image_counter += 1
      }
    end

    # Return whether this notebook as images or not.
    def has_images? : Bool
      cells.any? { |cell| cell.has_image? }
    end

    # Return a markdown rendering of this notebook.
    # Code cells are rendered as code blocks.
    # Images are rendered as a link.
    def to_markdown : String
      source = ""
      image_counter = 1
      @content.cells.each { |cell|
        if cell.is_markdown?
          csource = cell.source
          if csource
            source += "\n#{csource.join}\n"
          end
        elsif cell.is_code?
          csource = cell.source
          if csource
            source += "\n```\n#{csource.join}\n```\n"
          end
          # check if it has image
          if cell.has_image?
            source += "\n[#{@image_prefix}-#{image_counter}](./images/#{@image_prefix}-#{image_counter}.png)\n"
            image_counter += 1
          end
        end
      }
      return source
    end
  end
end
