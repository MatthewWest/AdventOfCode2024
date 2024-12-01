# Copyright 2022 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module AdventOfCode

export get_input, clear_input_cache, give_answer

using Dates: value
import HTTP
using JSON: JSON, json, parsefile, print
using TimeZones: TimeZone, ZonedDateTime, localzone, now

HEADERS = ["User-Agent" => "github.com/MatthewWest/AdventOfCode2022 by matthewwest217@gmail.com"]


_get_cache_directory() = joinpath(homedir(), ".advent-of-code")
_get_cookie_cache_path() = joinpath(_get_cache_directory(), "session-cookie.txt")
_get_input_cache_path(year, day) = joinpath(_get_cache_directory(), "$(year)", "day-$(day).txt")
_get_solution_cache_path(year, day) = joinpath(_get_cache_directory(), "$(year)", "day-$(day)-solutions.json")
_get_attempt_cache_path(year, day) = joinpath(_get_cache_directory(), "$(year)", "answers-day-$(day).json")

function _reset_cookie_cache()
    mkpath(dirname(cookie_cache_path))
    open(cookie_cache_path, "w") do f
        write(f, """A new Advent of Code session cookie is needed. Please do the following steps:
1) Log into the AdventOfCode account in Firefox.
2) Right click the page, and select "Inspect". Go to the storage tab of the developer tools.
3) Look at the session cookie and copy the value/content
4) Replace the contents of this file with the cookie.""")
    end
end

function _get_cookies()
    cookie_cache_path = _get_cookie_cache_path()
    if !isfile(cookie_cache_path)
        _reset_cookie_cache()
        error("Missing session cookie. Please update the cookie cache at $(cookie_cache_path).")
    end

    return Dict("session" => read(cookie_cache_path, String))
end

function _write_input_cache(year, day, r::HTTP.Response)
    path = _get_input_cache_path(year, day)
    mkpath(dirname(path))
    open(path, "w") do f
        write(f, r.body)
    end
end

function _time_until_midnight_eastern(year, day)
    ZonedDateTime(year, 12, day, 0, TimeZone("EST")) - now(localzone())
end

function _get_puzzle_page(year, day)
    url = "https://adventofcode.com/$(year)/day/$(day)"
    r = HTTP.get(url, HEADERS; cookies=_get_cookies())
    return String(r.body)
end

function _get_puzzle_answers(year, day)
    puzzle = _get_puzzle_page(year, day)
    answers = []
    i = 1
    while true
        m = match(r"Your puzzle answer was <code>(.*?)</code>", puzzle, i)
        if m === nothing
            break
        end
        push!(answers, parse(Int, m.captures[1]))
        i = m.offset + 1
    end
    while length(answers) < 2
        push!(answers, nothing)
    end
    answers
end

function get_input(year, day)
    # use the cached input if possible
    not_logged_in = "Puzzle inputs differ by user.  Please log in to get your puzzle input."
    too_early = "Please don't repeatedly request this endpoint before it unlocks! The calendar countdown is synchronized with the server time; the link will be enabled on the calendar the instant this puzzle becomes available."
    input_file_path = _get_input_cache_path(year, day)
    if isfile(input_file_path)
        contents = rstrip(read(input_file_path, String))
        if contents != not_logged_in && contents != too_early
            return contents
        end
    end

    # don't call the endpoint too early
    time_until_midnight = _time_until_midnight_eastern(year, day)
    if value(time_until_midnight) > 0
        error("Input not yet available. $(canonicalize(time_until_midnight)) left.")
    end

    url = "https://adventofcode.com/$(year)/day/$(day)/input"
    r = HTTP.get(url, HEADERS; status_exception=false, cookies=_get_cookies())
    
    if r.status == 200
        _write_input_cache(year, day, r)
    elseif r.status == 400
        _reset_cookie_cache()
        error("Invalid session cookie. Please update the cookie cache at $(_get_cookie_cache_path()).")
    elseif r.status == 404
        error("Attempted to call too early.")
    end
    return String(r.body)
end

function forget_input(year, day)
    rm(_get_input_cache_path(year, day); force=true)
end

function clear_input_cache()
    cache_dir = _get_cache_directory()
    cookie_file = _get_cookie_cache_path()

    for file ∈ walkdir(cache_dir)
        if file == cookie_file
            continue
        end
        rm(file)
    end
end

function _submit_answer_to_aoc(year, day, part, answer)
    TOO_RECENT_KEY = "You gave an answer too recently"
    BAD_ANSWER_KEYS = ["That's not the right answer",
                       "You don't seem to be solving the right level"]
    GOOD_ANSWER_KEY = "That's the right answer!"

    url = "https://adventofcode.com/$(year)/day/$(day)/answer"
    r = HTTP.post(url, HEADERS;
                    body=Dict("level" => part, "answer" => "$(answer)"),
                    cookies=_get_cookies())
    rbody = String(r.body)
    if occursin(GOOD_ANSWER_KEY, rbody)
        return true
    elseif occursin(TOO_RECENT_KEY, rbody)
        return false
    end
    for badkey ∈ BAD_ANSWER_KEYS
        if occursin(badkey, rbody)
            return false
        end
    end
    print("Response did not match any expected patterns.")
end

function _submit_answer(year, day, part, answer)
    answer_path = _get_attempt_cache_path(year, day)
    tried_answers = try
        parsefile(answer_path)
    catch
        Dict("1" => Dict(), "2" => Dict())
    end

    if haskey(tried_answers, "$(answer)")
        print("You already submitted $(answer) for $(year) day $(day) part $(part)!")
        return
    end

    submit_time = now(UTC)
    tried_answers["$(part)"]["$(answer)"] = submit_time

    good_answer = _submit_answer_to_aoc(year, day, part, answer)
    
    # save out the attempts
    mkpath(dirname(answer_path))
    open(answer_path, "w") do f
        JSON.print(f, tried_answers)
    end

    return good_answer
end

function give_answer(year, day, part, answer)
    solution_cache_path = _get_solution_cache_path(year, day)
    if isfile(solution_cache_path)
        solutions = open(solution_cache_path) do f
            parsefile(f, solution_cache_path)
        end
    else
        solutions = [nothing, nothing]
    end

    target = solutions[part]

    if part == 1
        println("The answer to part one is $(answer)")
    elseif part ==2
        println("The answer to part two is $(answer)")
    else
        error("Each problem only has two parts.")
    end

    if target !== nothing
        if "$(answer)" != target
            println("Incorrect answer!")
            error()
        end
    else
        print("Submit answer? ")
        response = readline()
        if lowercase(response) ∉ Set(["y", "yes", "1"])
            println("Aborting...")
            error()
        end

        isgood = _submit_answer(year, day, part, answer)
        if !isgood
            println("Answer not accepted.")
            error()
        end

        solutions[part] = "$(answer)"
        open(solution_cache_path, "w") do f
            JSON.print(f, solutions)
        end
    end
end
end