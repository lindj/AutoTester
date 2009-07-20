
class AutoTester
  def initialize filename, testfilename, autotest_prefix
    @filename = filename
    @testfilename = testfilename
    @autotest_prefix = autotest_prefix
  end
  def get_imports
    file = File.new(@testfilename, "rb")    
    content = file.read
    matches = content.scan(/import .*\;/)
  end

  def generate_class_def
    "public class " + @autotest_prefix + get_class_name + " extends TestCase"
  end
  def get_test_file_name
    @testfilename
  end
  
  #get private vars and setupfunction from @testfilename
  def get_setup_from_test
    file = File.new(@testfilename, "rb")    
    content = file.read
    body = content[content.index("\{")+1, content.length-1]

    startfun = body.index("\{")
    lefti = 0
    righti = 0
    cont = true

    while cont
      lefti += body[lefti+startfun+1, body.length].index("\{")+1
      righti += body[righti+startfun+1, body.length].index("\}")+1
      cont = false
      while lefti < righti
        lefti += body[lefti+startfun+1, body.length].index("\{")
        cont = true
      end
    end
    body[0, startfun+1+righti]
  end
  def get_class_name
    file = @filename.split("/")
    file[file.length-1].split(".")[0]   
  end
  def get_object_name
    declarations = get_setup_from_test
    name = get_class_name
    from = declarations.index(name)+name.length+1
    ret = declarations[from, declarations.length].split(";")[0]
    ret
  end
  def get_function_calls
    file = File.new(@filename, "rb")
    content = file.read
    functions = content.scan(/public.*\(.*\)/)
    ret = ""
    functions.each {|function|
      function = function.sub(/<.*>/, "")
      i = function.split("\(")[0].count(' ')
      if i == 3 or i == 2
        splitted = function.split(" ")
  
        func_name = splitted[2].slice! 0..splitted[2].index("\(").to_i-1
        if func_name.include?("(") == false
          ret.concat("\tpublic void test_"+func_name+"_nullInput() {\n\t\t")
          ret.concat(get_object_name + "."+func_name + "(")
            
          rest = function.slice! function.index("\(").to_i+1..function.length.to_i-2
          rest.strip
          if rest.include? ','
            rest[", "] = ","
            args_splitted = rest.split(',')
            nargs = args_splitted.length
            n = 0
            args_splitted.each {|arg|
              if arg.split(" ")[0] == "long"
                ret.concat("0")
              else
                ret.concat("null")
              end
              n = n+1
              if n < nargs
                ret.concat(",")
              end
              
              }
          else
            if rest.empty? == false
              if rest.split(" ")[0] == "long"
                ret.concat("0")
              else
                ret.concat("null")
              end
            end
          end
         
          ret.concat(");\n\t}\n")
        end
      end
    }
    ret
  end
end


