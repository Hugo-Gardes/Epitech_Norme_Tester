#!/usr/bin/ruby

require 'colorize'

$minor = 0
$major = 0
$info = 0

def char_is_not_string(char, line, index)
    i = 0
    is_good = true
    while (i < line.length())
        if ((line[i] == '"' or line[i] == '\'') and is_good)
            is_good = false
        elsif ((line[i] == '"' or line[i] == '\'') and is_good == false)
            is_good = true
        end
        if (line[i] == char and i == index and is_good)
            return (true)
        elsif (line[i] == char and i == index and is_good == false)
            return (false)
        end
        i += 1
    end
    return (false)
end

def check_return_without_parentheses(file, line, line_number)
    if line =~ /return/ #Si la ligne contient un return
        if line !~ /return.*\(.*\)/ #Si y'a pas de parantheses
            print ("[#{file}:#{line_number}]").yellow
            puts ("return without parantheses")
            $minor += 1
        end
    end
end

def check_more_than_5_functions(file)
    functionCount = 0
    descriptor = 0

    File.foreach(file) { |line|
        if (descriptor == 1 and line == "\{\n")
            functionCount += 1
        else
            descriptor = 0
        end
        if line =~ /.*\(.*\)/
            descriptor = 1
        end
    }
    if functionCount > 5
        print "[#{file}]".red
        puts(" too many functions in file : #{functionCount} > 5")
        $major += 1
    end
end

def check_line_too_long(file, line, line_number)
    if (line.length() > 80)
        print "[#{file}:#{line_number}]".red
        puts " too many char : #{line.length()} > 80"
        $major += 1
    end
end

def check_too_many_parameters(file)
    functionCount = 0
    descriptor = 0
    line_preced = ""
    comma = 0
    line_number = 0
    File.foreach(file) { |line|
        line_number += 1
        if (descriptor == 1 and line == "\{\n")
            comma = line_preced.count(',')
        else
            descriptor = 0
        end
        if line =~ /.*\(.*\)/
            descriptor = 1
            line_preced = line
        end
        if comma > 3
            comma += 1
            print "[#{file}: #{line_number}]".red
            puts " too many args on funct : #{line_preced}, #{comma} > 4"
            $major += 1
        end
        comma = 0
    }
end

def check_void_when_no_parameter(file)
    functionCount = 0
    descriptor = 0
    line_preced = ""
    line_number = 0
    File.foreach(file) { |line|
        line_number += 1
        if (descriptor == 1 and line == "\{\n")
            if (line_preced =~ /.*\(\)/)
                print "[#{file}: #{line_number}]".red
                puts " excepted void on empty descriptor : #{line_preced}"
                $major += 1
            end
        else
            descriptor = 0
        end
        if line =~ /.*\(.*\)/
            descriptor = 1
            line_preced = line
        end
    }
end

def check_nbr_lines(file)
    descriptor = 0
    line_count = 0
    bracket_open = 0
    bracket_close = 0
    line_number = 0
    line_funct = 0
    pass = 1
    File.foreach(file) { |line|
        line_number += 1
        if (bracket_open == 1 and pass == 1)
            pass = 0
            line_funct = line_number - 1
        end
        if (line =~ /.*\{.*/ and line !~ /\/\/*/)
            bracket_open += 1
        end
        if (line =~ /.*\}.*/ and line !~ /\/\/*/)
            bracket_close += 1
        end
        if (bracket_open == bracket_close)
            if (line_count > 20)
                print "[#{file}:#{line_funct}]".red
                puts " too long function: #{line_count} > 20"
                $major += 1
            end
            pass = 1
            line_count = 0
            bracket_open = 0
            bracket_close = 0
        end
        if (bracket_open >= 1)
            line_count += 1
            if (line =~ /.*\/\/.*/ or line =~ /.*\/\*/)
                print "[#{file}:#{line_number}]".yellow
                puts " comment inside function : #{line}"
                $minor += 1
            end
        end
    }
end

def check_bad_header_separation(file, line, line_number)
    if (line_number > 0 and line_number < 7)
        case(line_number)
            when 1
                if (line != "/*\n")
                    print "[#{file}:#{line_number}]".red
                    puts " error : bad header or corrupted header"
                    $major += 1
                end
            when 2
                if (line != "** EPITECH PROJECT, 2020\n" and line != "** EPITECH PROJECT, 2021\n")
                    print "[#{file}:#{line_number}]".red
                    puts " error : bad header or corrupted header"
                    $major += 1
                end
            when 3
                if (line !~ /\*\* .*\n/)
                    print "[#{file}:#{line_number}]".red
                    puts " error : bad header or corrupted header"
                    $major += 1
                end
            when 4
                if (line != "** File description:\n")
                    print "[#{file}:#{line_number}]".red
                    puts " error : bad header or corrupted header"
                    $major += 1
                end
            when 5
                if (line !~ /\*\* .*\n/)
                    print "[#{file}:#{line_number}]".red
                    puts " error : bad header or corrupted header"
                    $major += 1
                end
            when 6
                if (line != "*/\n")
                    print "[#{file}:#{line_number}]".red
                    puts " error : bad header or corrupted header"
                    $major += 1
                end
            end
    end
    if (line =~ /#define.*/)
        print "[#{file}:#{line_number}]".red
        puts (" define on .c : #{line}")
        $major += 1
    end
    if (line =~ /static.*\(.*\).*/)
        print "[#{file}:#{line_number}]".yellow
        puts (" static function on .c : #{line}")
        $minor += 1
    end
end

def check_indent(file, line, line_number)
    if (line =~ /                */)
        print "[#{file}:#{line_number}]".red
        puts (" must be less than 4 indent")
        $major += 1
    end
    if (line =~ /\t\t*/)
        print "[#{file}:#{line_number}]".red
        puts (" must start with space not tab")
        $major += 1
    end
end

def check_misplaced_space(file, line, line_number)
    index = 0
    is_end = false
    is_start = true
    nbr_space = 0
    if_is_space = false
    ib = 0
    while index < line.length() do
        if (line[index] == ',' and line[index + 1] != ' ' and line !~ /\/\/*/ and char_is_not_string(line[index], line, index))
            print "[#{file}:#{line_number}:#{index + 1}]".yellow
            puts " must have space after comma"
            $minor += 1
        end
        if (line[index] == ',' and line[index - 1] == ' ' and line !~ /\/\/*/ and char_is_not_string(line[index], line, index))
            print "[#{file}:#{line_number}:#{index + 1}]".yellow
            puts " misplaced space before comma"
            $minor += 1
        end
        ib = index
        while (is_start == false and ib < line.length() - 1) do
            if (line[ib] == ' ' or line[ib] == '\n')
                is_end = true
            else
                is_end = false
                break
            end
            ib += 1
        end
        if (is_end == false and is_start == false and line[index] == ' ' and line[index + 1] == ' ' and line !~ /\/\/*/ and char_is_not_string(line[index], line, index))
            print "[#{file}:#{line_number}:#{index + 1}]".yellow
            puts " misplaced space"
            $minor += 1
        end
        if (is_start == true and nbr_space == 4 and line[index] == ' ' and line[index + 1] != ' ' and line !~ /\/\/*/ and char_is_not_string(line[index], line, index))
            print "[#{file}:#{line_number}:#{index + 1}]".yellow
            puts " misplaced space"
            $minor += 1
        elsif (is_start == true and nbr_space == 4)
            nbr_space = 0
        end
        if (is_start == true and line[index] == ' ')
            nbr_space += 1
        end
        if (is_start == true and line[index] != ' ')
            is_start = false
        end
        if (is_start == false and (line[index] == ' ' or line[index] == '\t\t'))
            if_is_space = true
        elsif (is_start == false and (line[index] != ' ' and line[index] != '\t\t'))
            if_is_space = false
        end
        if (index == (line.length() - 2) and if_is_space == true and line !~ /\/\/*/)
            print "[#{file}:#{line_number}]".green
            puts " trailing space"
            $info += 1
        end
        index += 1
    end
end

def check_match(line, index, str2)
    i = 0
    while (i < str2.length())
        if (line[index + i] != str2[i])
            return (false)
        end
        i += 1
    end
    return (true)
end

def check_misplaced_space_bis(file, line, line_number)
    i = 0
    is_enter = false
    while (line[i] and line !~ /.*\/\/*/)
        if (check_match(line, i, " return(") and char_is_not_string(line[i], line, i) == false)
            print "[#{file}:#{line_number}:#{i}]".yellow
            puts " missing space after return"
            $minor += 1
        end
        if (check_match(line, i, " for(") and char_is_not_string(line[i], line, i) == false)
            print "[#{file}:#{line_number}:#{i}]".yellow
            puts " missing space after for"
            $minor += 1
        end
        if (check_match(line, i, " while(") and char_is_not_string(line[i], line, i) == false)
            print "[#{file}:#{line_number}:#{i}]".yellow
            puts " missing space after while"
            $minor += 1
        end
        if (check_match(line, i, " if(") and char_is_not_string(line[i], line, i) == false)
            print "[#{file}:#{line_number}:#{i}]".yellow
            puts " missing space after if"
            $minor += 1
        end
        if (check_match(line, i, " }else") and char_is_not_string(line[i], line, i) == false)
            print "[#{file}:#{line_number}:#{i}]".yellow
            puts " missing space before else"
            $minor += 1
        end
        if (check_match(line, i, " switch(") and char_is_not_string(line[i], line, i) == false)
            print "[#{file}:#{line_number}:#{i}]".yellow
            puts " missing space after switch"
            $minor += 1
        end
        if (check_match(line, i, "% (") == false and char_is_not_string(line[i], line, i) and check_match(line, i, " void *(") == false and check_match(line, i, " void (") == false and check_match(line, i, " int *(") == false and check_match(line, i, " char *(") == false and check_match(line, i, " char (") == false and check_match(line, i, " int (") == false and check_match(line, i, "switch (") == false and check_match(line, i, "sizeof(") == false and check_match(line, i, "  (") == false and check_match(line, i, ", (") == false and check_match(line, i, "= (") == false and check_match(line, i, " return (") == false and check_match(line, i, " for (") == false and check_match(line, i, " while (") == false and check_match(line, i, " if (") == false)
            if (check_match(line, i, " (") == true and is_enter == false)
                print "[#{file}:#{line_number}:#{i}]".yellow
                puts " missplaced space beetween funct and ("
                is_enter = true
                $minor += 1
            end
        elsif (char_is_not_string(line[i], line, i) and (check_match(line, i, "% (") == true or check_match(line, i, " void *(") == true or check_match(line, i, " void (") == true or check_match(line, i, " int *(") == true or check_match(line, i, " char *(") == true or check_match(line, i, " char (") == true or check_match(line, i, " int (") == true or check_match(line, i, "switch (") == true or check_match(line, i, "sizeof(") == true or check_match(line, i, "  (") == true or check_match(line, i, ", (") == true or check_match(line, i, "= (") == true or check_match(line, i, " return (") == true or check_match(line, i, " for (") == true or check_match(line, i, " while (") == true or check_match(line, i, " if (") == true))
            is_enter = true
        end
        i += 1
    end
end

def parseFile(file)
    check_more_than_5_functions(file)
    check_too_many_parameters(file)
    check_void_when_no_parameter(file)
    check_nbr_lines(file)

    line_number = 1
    File.foreach(file) { |line|
        # check_multi_asignement(file, line, line_number)
        check_bad_header_separation(file, line, line_number)
        check_return_without_parentheses(file, line, line_number)
        check_line_too_long(file, line, line_number)
        check_indent(file, line, line_number)
        check_misplaced_space(file, line, line_number)
        check_misplaced_space_bis(file, line, line_number)
        line_number += 1
    }
end

require 'find'
Find.find('.') { |f|
    if ((f !~ /tester.rb/ and f !~ /.*\.txt/ and f !~ /.*\.c/ and f !~ /.*\.h/ and f != "." and File.file?(f) and f != "./Makefile" and f !~ /.*\.png/ and f !~ /.*\.jpg/ and f !~ /.*\.ttf/ and f !~ /\.git.*/ and f !~ /.*\.xml/ and f !~ /.*\.mp3/ and f !~ /.*\.mp4/ and f !~ /.*\.ogg/) or f =~ /#*#/ or f =~ /.*~/ or f =~ /.*.break/)
        f.slice!(0, 2)
        print "[#{f}]".red
        puts " not a require for compilation"
        $major += 1
    end
    if (f =~ /.*\.c/ and f !~ /#*#/ and f !~ /.*~/ and f !~ /.*.break/)
        f.slice!(0, 2)
        parseFile(f)
    end
}

print "\nmajor = #{$major}".red
print ", "
print "minor = #{$minor}".yellow
print ", "
print "info = #{$info}\n".green