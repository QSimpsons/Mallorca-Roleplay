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

yes(SnelleOwner.same('char1:abc123', idents), 'zelfde karakter')
yes(SnelleOwner.same('license:abc123', idents), 'dealer slaat license op')
yes(SnelleOwner.same('CHAR1:ABC123', idents), 'hoofdletters')
yes(SnelleOwner.same('abc123', idents), 'kale hash')
yes(SnelleOwner.same(' steam:abc123 ', idents), 'steam met spaties')
no(SnelleOwner.same('char2:andere', idents), 'ander personage')
no(SnelleOwner.same('license:iemandanders', idents), 'andere speler')
no(SnelleOwner.same('', idents), 'lege eigenaar')
no(SnelleOwner.same('char1:abc123', nil), 'geen identifiers')

local unique = SnelleOwner.unique({ 'char1:abc123', 'char1:abc123', '', 'license:abc123' })
yes(#unique == 2, 'dubbele identifiers vallen weg')

local now = 1000
local window = 60
yes(SnelleOwner.purchaseMatches({ ident = 'char1:abc123', at = 980 }, idents, now, window), 'verse aankoop')
yes(SnelleOwner.purchaseMatches({ ident = 'license:abc123', at = 1000 }, idents, now, window), 'aankoop op license')
no(SnelleOwner.purchaseMatches({ ident = 'char1:abc123', at = 900 }, idents, now, window), 'te oude aankoop')
no(SnelleOwner.purchaseMatches({ ident = 'char2:andere', at = 990 }, idents, now, window), 'aankoop van iemand anders')
no(SnelleOwner.purchaseMatches(nil, idents, now, window), 'geen aankoop')

print(('ok %d checks'):format(passed))
