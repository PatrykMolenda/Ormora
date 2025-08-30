RegisterCommand('run_test', function(source, args, rawCommand)
    if source ~= 0 then
        print('This command can only be run from the server console.')
        return
    end

    local testName = args[1]
    if not testName then
        print('Please provide a test name')
        return
    end

    local timeBefore = os.clock()
    local test = require('tests.tests.' .. testName)
    local statuses = test:run()
    for i, status in ipairs(statuses) do
        print(string.format('Test %d: %s', i, status and 'Passed' or 'Failed'))
    end
    print(string.format('All tests completed in %.4f seconds', os.clock() - timeBefore))
end)