using Match
using JSON
# Maximum distance(difference) for a trigram in a language profile and text profile.
 const MAX_TRIGRAM_DISTANCE = 300;

# 300 trigrams where each has MAX_TOTAL_DISTANCE=300, gives us 90_000.
 const MAX_TOTAL_DISTANCE = 90_000;

# Double MAX_TRIGRAM_DISTANCE
 const TEXT_TRIGRAMS_SIZE = 600;

const RELIABLE_CONFIDENCE_THRESHOLD = 0.8;

function detect_script(text::AbstractString)
    script_counters = [
      [LatinScript()      , 0],
      [CyrillicScript()   , 0],
      [ArabicScript()     , 0],
      [MandarinScript()   , 0],
      [DevanagariScript() , 0],
      [HebrewScript()     , 0],
      [EthiopicScript()   , 0],
      [GeorgianScript()   , 0],
      [BengaliScript()    , 0],
      [HangulScript()     , 0],
      [HiraganaScript()   , 0],
      [KatakanaScript()   , 0],
      [GreekScript()      , 0],
      [KannadaScript()    , 0],
      [TamilScript()      , 0],
      [ThaiScript()       , 0],
      [GujaratiScript()   , 0],
      [GurmukhiScript()   , 0],
      [TeluguScript()     , 0],
      [MalayalamScript()  , 0],
      [OriyaScript()      , 0],
      [MyanmarScript()    , 0],
      [SinhalaScript()    , 0],
      [KhmerScript()      , 0]
    ]

    half = length(text) / 2
    local found
    for ch in text
        if is_stop_char(ch); continue; end
        for i in 1:length(script_counters)
            (script, count) = script_counters[i]
            found = false
            if is_script(script, ch)
                script_counters[i][2] += 1
                found=true
                if script_counters[i][2] > half; return script; end
            end
            # If script was found, move it closer to the front.
            # If the text contains largely 1 or 2 scripts, this will
            # cause these scripts to be eventually checked first.
            if found && i>1
                t=script_counters[i-1]
                script_counters[i-1] = script_counters[i]
                script_counters[i] = t
            end
        end
    end

    sort(script_counters, lt=(x,y)->x[2]<y[2])
    if script_counters[2] > 0
        return script_counters[1]
    else
        return nothing
    end


end

function is_script(::CyrillicScript, ch::Char)
   @match ch begin
       '\u0400':'\u0484' || '\u0487':'\u052F' || '\u2DE0':'\u2DFF' || '\uA640':'\uA69D' || '\u1D2B' || '\u1D78' || '\uA69F' => true
       _ => false
   end
end

# https:#en.wikipedia.org/wiki/Latin_script_in_Unicode
function is_script(::LatinScript, ch::Char)
    @match ch begin
        'a':'z' || 'A':'Z' || '\u0080':'\u00FF' || '\u0100':'\u017F' || '\u0180':'\u024F' || '\u0250':'\u02AF' || '\u1D00':'\u1D7F' || '\u1D80':'\u1DBF' || '\u1E00':'\u1EFF' || '\u2100':'\u214F' || '\u2C60':'\u2C7F' || '\uA720':'\uA7FF' || '\uAB30':'\uAB6F' => true
        _ => false
    end
end

# Based on https:#en.wikipedia.org/wiki/Arabic_script_in_Unicode
function is_script(::ArabicScript, ch::Char)
    @match ch begin
        '\u0600':'\u06FF' || '\u0750':'\u07FF' || '\u08A0':'\u08FF' || '\uFB50':'\uFDFF' || '\uFE70':'\uFEFF'  => true  #|| '\u10E60':'\u10E7F' || '\u1EE00':'\u1EEFF'
        _ => false
    end
end

# Based on https:#en.wikipedia.org/wiki/Devanagari#Unicode
function is_script(::DevanagariScript, ch::Char)
    @match ch begin
        '\u0900':'\u097F' || '\uA8E0':'\uA8FF' || '\u1CD0':'\u1CFF' => true
        _ => false
    end
end

# Based on https:#www.key-shortcut.com/en/writing-systems/ethiopian-script/
function is_script(::EthiopicScript, ch::Char)
    @match ch begin
        '\u1200':'\u139F' || '\u2D80':'\u2DDF' || '\uAB00':'\uAB2F' => true
        _ => false
    end
end

# Based on https:#en.wikipedia.org/wiki/Hebrew_(Unicode_block)
function is_script(::HebrewScript, ch::Char)
    @match ch begin
        '\u0590':'\u05FF' => true
        _ => false
    end
end

function is_script(::GeorgianScript, ch::Char)
   @match ch begin
       '\u10A0':'\u10FF' => true
       _ => false
   end
end

function is_script(::MandarinScript, ch::Char)
    @match ch begin
        '\u2E80':'\u2E99' || '\u2E9B':'\u2EF3' || '\u2F00':'\u2FD5' || '\u3005' || '\u3007' || '\u3021':'\u3029' || '\u3038':'\u303B' || '\u3400':'\u4DB5' || '\u4E00':'\u9FCC' || '\uF900':'\uFA6D' || '\uFA70':'\uFAD9' => true
        _ => false
    end
end

function is_script(::BengaliScript, ch::Char)
   @match ch begin
       '\u0980':'\u09FF' => true
       _ => false
   end
end

function is_script(::HiraganaScript, ch::Char)
   @match ch begin
       '\u3040':'\u309F' => true
       _ => false
   end
end

function is_script(::KatakanaScript, ch::Char)
   @match ch begin
       '\u30A0':'\u30FF' => true
       _ => false
    end
end


# Hangul is Korean Alphabet. Unicode ranges are taken from: https:#en.wikipedia.org/wiki/Hangul
function is_script(::HangulScript, ch::Char)
    @match ch begin
        '\uAC00':'\uD7AF' || '\u1100':'\u11FF' || '\u3130':'\u318F' || '\u3200':'\u32FF' || '\uA960':'\uA97F' || '\uD7B0':'\uD7FF' || '\uFF00':'\uFFEF' => true
        _ => false
    end
end

# Taken from: https:#en.wikipedia.org/wiki/Greek_and_Coptic
function is_script(::GreekScript, ch::Char)
    @match ch begin
        '\u0370':'\u03FF' => true
        _ => false
    end
end

# Based on: https:#en.wikipedia.org/wiki/Kannada_(Unicode_block)
function is_script(::KannadaScript, ch::Char)
    @match ch begin
        '\u0C80':'\u0CFF' => true
        _ => false
    end
end

# Based on: https:#en.wikipedia.org/wiki/Tamil_(Unicode_block)
function is_script(::TamilScript, ch::Char)
    @match ch begin
        '\u0B80':'\u0BFF' => true
        _ => false
    end
end

# Based on: https:#en.wikipedia.org/wiki/Thai_(Unicode_block)
function is_script(::ThaiScript, ch::Char)
    @match ch begin
        '\u0E00':'\u0E7F' => true
        _ => false
    end
end

# Based on: https:#en.wikipedia.org/wiki/Gujarati_(Unicode_block)
function is_script(::GujaratiScript, ch::Char)
    @match ch begin
        '\u0A80':'\u0AFF' => true
        _ => false
    end
end

# Gurmukhi is the script for Punjabi language.
# Based on: https:#en.wikipedia.org/wiki/Gurmukhi_(Unicode_block)
function is_script(::GurmukhiScript, ch::Char)
    @match ch begin
        '\u0A00':'\u0A7F' => true
        _ => false
    end
end

function is_script(::TeluguScript, ch::Char)
    @match ch begin
        '\u0C00':'\u0C7F' => true
        _ => false
    end
end

# Based on: https:#en.wikipedia.org/wiki/Malayalam_(Unicode_block)
function is_script(::MalayalamScript, ch::Char)
    @match ch begin
        '\u0D00':'\u0D7F' => true
        _ => false
    end
end

# Based on: https:#en.wikipedia.org/wiki/Malayalam_(Unicode_block)
function is_script(::OriyaScript, ch::Char)
    @match ch begin
        '\u0B00':'\u0B7F' => true
        _ => false
    end
end

# Based on: https:#en.wikipedia.org/wiki/Myanmar_(Unicode_block)
function is_script(::MyanmarScript, ch::Char)
    @match ch begin
        '\u1000':'\u109F' => true
        _ => false
    end
end

# Based on: https:#en.wikipedia.org/wiki/Sinhala_(Unicode_block)
function is_script(::SinhalaScript, ch::Char)
    @match ch begin
        '\u0D80':'\u0DFF' => true
        _ => false
    end
end

# Based on: https:#en.wikipedia.org/wiki/Khmer_alphabet
function is_script(::KhmerScript, ch::Char)
    @match ch begin
        '\u1780':'\u17FF' || '\u19E0':'\u19FF' => true
        _ => false
    end
end

function is_stop_char(ch::Char)
    @match ch begin
        '\u0000':'\u0040' || '\u005B':'\u0060' || '\u007B':'\u007E' => true
        _ => false
    end
end


### Trigram model

function to_trigram_char(ch::Char)
    if is_stop_char(ch); ' ' ; else ch; end
end

function count_trigrams(text::AbstractString)
    counter_hash  = Dict{String, Int}()
    text = string(text, ' ')
    #iterate through the string and count trigram
    chars_iter = (lowercase(to_trigram_char(x)) for x in text)
    c1 = ' ';
    state = start(chars_iter)
    c2, state = next(chars_iter, state)
    while !done(chars_iter, state)
        c3, state  = next(chars_iter, state)
        if !(c2 == ' ' && (c1 == ' ' || c3 == ' '))
            trigram = string(c1, c2, c3)
            counter_hash[trigram] = get(counter_hash, trigram, 0) + 1
        end
        c1 = c2;
        c2 = c3;
    end
    return counter_hash
end

function get_trigrams_with_positions(text::String)
    count_vec = [(v,k) for (k, v) in count_trigrams(text)]
    sort!(count_vec, rev=true)
    Dict(tri => i for (i, (c, tri)) in enumerate(count_vec[1:min(length(count_vec), TEXT_TRIGRAMS_SIZE)]))
end

detect_lang_based_on_script(text::AbstractString, script::LatinScript, options) = detect_lang_trigrams(text, script, options)
detect_lang_based_on_script(text::AbstractString, script::CyrillicScript, options) = detect_lang_trigrams(text, script, options)
detect_lang_based_on_script(text::AbstractString, script::DevanagariScript, options) = detect_lang_trigrams(text, script, options)
detect_lang_based_on_script(text::AbstractString, script::HebrewScript, options) = detect_lang_trigrams(text, script, options)
detect_lang_based_on_script(text::AbstractString, script::EthiopicScript, options) = detect_lang_trigrams(text, script, options)
detect_lang_based_on_script(text::AbstractString, script::ArabicScript, options) = detect_lang_trigrams(text, script, options)
detect_lang_based_on_script(text::AbstractString, script::MandarinScript, options) = ("Cmn", 1.0)
detect_lang_based_on_script(text::AbstractString, script::BengaliScript, options) = ("Ben", 1.0)
detect_lang_based_on_script(text::AbstractString, script::HangulScript, options) = ("Kor", 1.0)
detect_lang_based_on_script(text::AbstractString, script::GeorgianScript, options) = ("Kat", 1.0)
detect_lang_based_on_script(text::AbstractString, script::GreekScript, options) = ("Ell", 1.0)
detect_lang_based_on_script(text::AbstractString, script::KannadaScript, options) = ("Kan", 1.0)
detect_lang_based_on_script(text::AbstractString, script::TamilScript, options) = ("Tam", 1.0)
detect_lang_based_on_script(text::AbstractString, script::ThaiScript, options) = ("Tha", 1.0)
detect_lang_based_on_script(text::AbstractString, script::GujaratiScript, options) = ("Guj", 1.0)
detect_lang_based_on_script(text::AbstractString, script::GurmukhiScript, options) = ("Pan", 1.0)
detect_lang_based_on_script(text::AbstractString, script::TeluguScript, options) = ("Tel", 1.0)
detect_lang_based_on_script(text::AbstractString, script::MalayalamScript, options) = ("Mal", 1.0)
detect_lang_based_on_script(text::AbstractString, script::OriyaScript, options) = ("Ori", 1.0)
detect_lang_based_on_script(text::AbstractString, script::MyanmarScript, options) = ("Mya", 1.0)
detect_lang_based_on_script(text::AbstractString, script::SinhalaScript, options) = ("Sin", 1.0)
detect_lang_based_on_script(text::AbstractString, script::KhmerScript, options) = ("Khm", 1.0)
detect_lang_based_on_script(text::AbstractString, script::Union{HiraganaScript, KatakanaScript}, options) = ("Jpn", 1.0)


@enum DetectType Trigram=1 Deep=2

struct LangDetectOptions
    model::DetectType
    whitelist::Union{Void, Vector{Language}}
    blacklist::Union{Void, Vector{Language}}
end

default_options() = LangDetectOptions(Trigram, Vector{Language}(), Vector{Language}())

detect_lang_trigrams(text::AbstractString, script::Script, options) = detect_lang_trigrams(text, trigram_models[name(script)], options)

function detect_lang_trigrams(text::AbstractString, lang_trigrams_list::Dict{String, Vector{String}}, options )
    lang_distances = Vector{Tuple{String, Int}}()
    trigrams = get_trigrams_with_positions(text)

    for (lang, lang_trigrams) in lang_trigrams_list

        if !isempty(options.whitelist) && !contains(==, options.whitelist, lang); continue; end
        if !isempty(options.blacklist) && contains(==, options.blacklist, lang); continue; end

        dist = calculate_distance(lang_trigrams, trigrams)
        push!(lang_distances, (lang, dist))
    end

    # Sort languages by distance
    sort!(lang_distances, lt=(x, y)->x[2]<y[2])

    # Return None if lang_distances is empty
    if isempty(lang_distances); return (nothing, 0.0); end
    # Return the only language with is_reliable=true if there is only 1 item
    if length(lang_distances) == 1
        return (lang_distances[1][1], 1.0)
    end

    # Calculate is_reliable based on:
    # - number of unique trigrams in the text
    # - rate (diff between score of the first and second languages)
    #
    lang_dist1 = lang_distances[1]
    lang_dist2 = lang_distances[2]
    score1 = MAX_TOTAL_DISTANCE - lang_dist1[2]
    score2 = MAX_TOTAL_DISTANCE - lang_dist2[2]

    if score1 == 0
        # If score1 is 0, score2 is 0 as well, because array is sorted.
        # Therefore there is not language to return.
        return (nothing, 0.0)
    elseif score2 == 0
        # If score2 is 0, return first language, to prevent division by zero in the rate formula.
        # In this case confidence is calculated by another formula.
        # At this point there are two options:
        # * Text contains random characters that accidentally match trigrams of one of the languages
        # * Text really matches one of the languages.
        #
        # Number 500.0 is based on experiments and common sense expectations.
        confidence = score1 / 500.0
        if confidence > 1.0
            confidence = 1.0
        end
        return (lang_dist1[1], confidence)
    end

    rate = (score1 - score2) / score2

    # Hyperbola function. Everything that is above the function has confidence = 1.0
    # If rate is below, confidence is calculated proportionally.
    # Numbers 12.0 and 0.05 are obtained experimentally, so the function represents common sense.
    #
    confident_rate = (12.0 / length(trigrams)) + 0.05
    confidence = (rate > confident_rate) ? 1.0 : rate / confident_rate

    return (lang_dist1[1], confidence)
end


function calculate_distance(lang_trigrams,  text_trigrams)
    total_dist = 0
    for (i, trigram) in enumerate(lang_trigrams)
        dist = get(text_trigrams, trigram, MAX_TRIGRAM_DISTANCE+i) - i
        total_dist += abs(dist)
    end
    total_dist
end

function detect(text::AbstractString, options=default_options())
    script = detect_script(text)
    lang, conf = detect_lang_based_on_script(text, script, options)
    return (from_code(lang), script, conf)
end