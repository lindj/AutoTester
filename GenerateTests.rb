require 'AutoTester.rb'
require 'fileutils'

#PATHS
$basepath = "../rich/rich_log_server/src/burt/rich/"
$testpath = $basepath+"test/"
$autotestpath = $basepath+"autotest/"

#NAMES
$autotest_prefix = "TestAuto"
$autotest_package_name = "burt.rich.autotest"

class GenerateTests
  def iterate_test_dir
    contains = Dir.new($testpath).entries
    contains.each { |file| 
      if file.match(/Test.*/)
        save_to(generate_test_from_test(file, $basepath),$autotestpath+$autotest_prefix+file[4, file.length])
      end
    }
  end
  def save_to content, filename
    file = File.new(filename, "w")
    file.write(content)
  end

  def generate_test_from_test testfilename, basepath
    filename = testfilename[4, testfilename.length]
    generate_test(basepath+filename, $testpath+testfilename, $autotest_package_name)
  end
  def generate_test filename, testfilename, package
    at = AutoTester.new filename, testfilename, $autotest_prefix
    tosave = "package " + package + ";\n"
    tosave.concat(at.get_imports.collect{|a| a + ";\n"}.to_s.chop.chop)
    tosave.concat("\n")
    tosave.concat("\n")
    tosave.concat(at.generate_class_def + " { \n")
    tosave.concat(at.get_setup_from_test)
    tosave.concat("\n")
    tosave.concat(at.get_function_calls)
    tosave.concat("\n}\n")
    tosave
  end
end


if ARGV.length > 0
  if ARGV[0] == "remove"
    FileUtils.rm_rf $autotestpath
    exit
  end
end
FileUtils.mkdir_p $autotestpath
gt = GenerateTests.new
gt.iterate_test_dir()
