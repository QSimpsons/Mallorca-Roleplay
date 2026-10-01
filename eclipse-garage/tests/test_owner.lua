local root = arg[0]:match('^(.*)/') or '.'
dofile(root .. '/../shared/owner.lua')

local passed = 0

local function yes(value, label)
    if not value then
        error(label, 2)
    end
    passed = passed + 1
end

local function no(value, label)
    if value then
        error(label, 2)
    end
    passed = passed + 1
end

local idents = {
    'char1:abc123',
    'license:abc123',
    'license2:abc123',
}

yes(EclipseOwner.same('char1:abc123', idents), 'zelfde karakter')
yes(EclipseOwner.same('license:abc123', idents), 'dealer slaat license op')
yes(EclipseOwner.same('CHAR1:ABC123', idents), 'hoofdletters')
yes(EclipseOwner.same('abc123', idents), 'kale hash')
no(EclipseOwner.same('char2:andere', idents), 'ander personage')
no(EclipseOwner.same('license:iemandanders', idents), 'andere speler')
no(EclipseOwner.same('', idents), 'lege eigenaar')
no(EclipseOwner.same('char1:abc123', nil), 'geen identifiers')

local unique = EclipseOwner.unique({ 'char1:abc123', 'char1:abc123', '', 'license:abc123' })
yes(#unique == 2, 'dubbele identifiers vallen weg')

print(('ok %d checks'):format(passed))
