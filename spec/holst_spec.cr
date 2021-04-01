require "spec"
require "../src/holst.cr"

describe "Jupyter" do
  describe "Running Code notebook" do
    it "must parse the correct number of cells" do
      notebook = Holst::JupyterFile.new("#{__DIR__}/notebooks/RunningCode.ipynb")
      notebook.cells.size.should eq(28)
    end
    it "must get correct number of markdown cells" do
      notebook = Holst::JupyterFile.new("#{__DIR__}/notebooks/RunningCode.ipynb")
      md_cells = notebook.cells.select { |cell| cell.type == Holst::CellType::MARKDOWN }
      md_cells.size.should eq(19)
    end
    it "must parse correctly when notebook has no images" do
      notebook = Holst::JupyterFile.new("#{__DIR__}/notebooks/RunningCode.ipynb")
      notebook.has_images?.should eq(false)
    end
    it "must parse kernel name correctly" do
      notebook = Holst::JupyterFile.new("#{__DIR__}/notebooks/RunningCode.ipynb")
      notebook.metadata.kernelspec.name.should eq("python3")
    end
    it "must parse kernel display name correctly" do
      notebook = Holst::JupyterFile.new("#{__DIR__}/notebooks/RunningCode.ipynb")
      notebook.metadata.kernelspec.display_name.should eq("Python 3")
    end
    it "must parse kernel language correctly" do
      notebook = Holst::JupyterFile.new("#{__DIR__}/notebooks/RunningCode.ipynb")
      notebook.metadata.kernelspec.language.should eq("python")
    end
  end
  describe "SVM notebook" do
    it "must parse the correct number of cells" do
      notebook = Holst::JupyterFile.new("#{__DIR__}/notebooks/SVM.ipynb")
      notebook.cells.size.should eq(62)
    end
    it "must get correct number of markdown cells" do
      notebook = Holst::JupyterFile.new("#{__DIR__}/notebooks/SVM.ipynb")
      md_cells = notebook.cells.select { |cell| cell.type == Holst::CellType::MARKDOWN }
      md_cells.size.should eq(36)
    end
    it "must parse correctly when notebook has images" do
      notebook = Holst::JupyterFile.new("#{__DIR__}/notebooks/SVM.ipynb")
      notebook.has_images?.should eq(true)
    end
    it "must parse kernel name correctly" do
      notebook = Holst::JupyterFile.new("#{__DIR__}/notebooks/SVM.ipynb")
      notebook.metadata.kernelspec.name.should eq("python3")
    end
    it "must parse kernel display name correctly" do
      notebook = Holst::JupyterFile.new("#{__DIR__}/notebooks/SVM.ipynb")
      notebook.metadata.kernelspec.display_name.should eq("Python 3")
    end
    it "must parse kernel language correctly" do
      notebook = Holst::JupyterFile.new("#{__DIR__}/notebooks/SVM.ipynb")
      notebook.metadata.kernelspec.language.should eq("python")
    end
  end
end
