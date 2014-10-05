local gumbo = require "gumbo"

do
    local input = "\t\t<!--one--><!--two--><h1>Hi</h1>"
    local document = assert(gumbo.parse(input, 16))
    local html = assert(document.documentElement)

    -- Check that document structure is as expected
    assert(document.childNodes.length == 3)
    assert(#document.childNodes == 3)
    assert(html == document[3])
    assert(document[1].data == "one")
    assert(document[2].data == "two")
    assert(html.innerHTML == "<head></head><body><h1>Hi</h1></body>")

    -- Check that tab_stop parameter is used
    assert(document[1].line == 1)
    assert(document[1].column == 32)
    assert(document[1].offset == 2)
end

do -- Make sure deeply nested elements don't cause a stack overflow
    local input = string.rep("<div>", 500)
    local document = assert(gumbo.parse(input), "stack check failed")
    assert(document.body[1][1][1][1][1][1][1][1][1][1][1].localName == "div")
end

do -- Check that parse_file works the same with a filename as with a file
    local to_table = require "gumbo.serialize.table"
    local a = assert(gumbo.parse_file(io.open("test/t1.html"), 4))
    local b = assert(gumbo.parse_file("test/t1.html", 4))
    assert(to_table(a) == to_table(b))

    -- Ensure that serialized table syntax is valid
    local fn = assert((loadstring or load)('return ' .. to_table(a)))
    local t = assert(fn())
    assert(type(t) == "table")
end

-- Check that file open/read errors are handled
assert(not gumbo.parse_file(0), "Passing invalid argument type should fail")
assert(not gumbo.parse_file".", "Passing a directory name should fail")
assert(not gumbo.parse_file"_", "Passing a non-existant filename should fail")
