
module DataTables
  def self.root
    @root ||= Pathname.new(File.expand_path('../', File.dirname(__FILE__)))
  end
end
