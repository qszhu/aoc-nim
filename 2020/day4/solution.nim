import ../../lib/imports



type
  Passport = Table[string, string]

proc parseBlock(lines: string): Passport =
  for line in lines.split("\n"):
    for kvs in line.split(" "):
      let p = kvs.split(":")
      result[p[0]] = p[1]

proc parse(input: string): seq[Passport] =
  input.split("\n\n").mapIt(it.parseBlock)

when defined(test):
  let input = """
ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in
""".strip
  block:
    let res = input.parse
    doAssert res.len == 4
    doAssert res[0]["eyr"] == "2020"
    doAssert res[^1]["ecl"] == "brn"



proc isValid(p: Passport): bool =
  @["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"].allIt(it in p)

proc part1(input: string): int =
  input.parse.countIt(it.isValid)

when defined(test):
  block:
    doAssert part1(input) == 2



proc checkYear(s: string, lo, hi: int): bool =
  if not s.match(re"^\d{4}$"): return
  s.parseInt in lo .. hi

proc checkBirthYear(s: string): bool =
  s.checkYear(1920, 2002)

when defined(test):
  block:
    doAssert "2002".checkBirthYear
    doAssert not "2003".checkBirthYear

proc checkIssueYear(s: string): bool =
  s.checkYear(2010, 2020)

proc checkExpirationYear(s: string): bool =
  s.checkYear(2020, 2030)

proc checkHeight(s: string): bool =
  if not s.match(re"^\d+(cm|in)$"): return
  if s.endsWith("cm"):
    return s[0 ..< ^2].parseInt in 150 .. 193
  if s.endsWith("in"):
    return s[0 ..< ^2].parseInt in 59 .. 76

when defined(test):
  block:
    doAssert "60in".checkHeight
    doAssert "190cm".checkHeight
    doAssert not "190in".checkHeight
    doAssert not "190".checkHeight

proc checkHairColor(s: string): bool =
  s.match(re"^#[0-9a-f]{6}$")

when defined(test):
  block:
    doAssert "#123abc".checkHairColor
    doAssert not "#123abz".checkHairColor
    doAssert not "123abc".checkHairColor

proc checkEyeColor(s: string): bool =
  s in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]

when defined(test):
  block:
    doAssert "brn".checkEyeColor
    doAssert not "wat".checkEyeColor

proc checkPassportID(s: string): bool =
  s.match(re"^\d{9}$")

when defined(test):
  block:
    doAssert "000000001".checkPassportID
    doAssert not "0123456789".checkPassportID

proc isValid2(p: Passport): bool =
  result = true
  if "byr" notin p or not p["byr"].checkBirthYear: return false
  if "iyr" notin p or not p["iyr"].checkIssueYear: return false
  if "eyr" notin p or not p["eyr"].checkExpirationYear: return false
  if "hgt" notin p or not p["hgt"].checkHeight: return false
  if "hcl" notin p or not p["hcl"].checkHairColor: return false
  if "ecl" notin p or not p["ecl"].checkEyeColor: return false
  if "pid" notin p or not p["pid"].checkPassportID: return false

when defined(test):
  block:
    let input = """
eyr:1972 cid:100
hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

iyr:2019
hcl:#602927 eyr:1967 hgt:170cm
ecl:grn pid:012533040 byr:1946

hcl:dab227 iyr:2012
ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

hgt:59cm ecl:zzz
eyr:2038 hcl:74454a iyr:2023
pid:3556412378 byr:2007
""".strip
    doAssert input.parse.mapIt(it.isValid2).allIt(not it)

  block:
    let input = """
pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
hcl:#623a2f

eyr:2029 ecl:blu cid:129 byr:1989
iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

hcl:#888785
hgt:164cm byr:2001 iyr:2015 cid:88
pid:545766238 ecl:hzl
eyr:2022

iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
""".strip
    doAssert input.parse.mapIt(it.isValid2).allIt(it)

proc part2(input: string): int =
  input.parse.countIt(it.isValid2)



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
