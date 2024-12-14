Mix.install([
  {:kino, "~> 0.14.2"},
  {:kino_aoc, "~> 0.1.7"},
])

example = """
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
"""

{_, input} = if false do
  KinoAOC.download_puzzle("2024", "13", System.fetch_env!("LB_AOC_SESSION"))
else
  {:ok, example}
end

parse_num_pair = fn button_or_prize -> button_or_prize
  |> String.split(",")
  |> Enum.map(
    fn piece ->
      String.replace(piece, ~r/[^\d]/, "") |> String.to_integer()
    end)
  |> List.to_tuple()
end

parse_machine = fn string ->
  parts = String.split(string, "\n")
  a_xy = Enum.at(parts, 0) |> parse_num_pair.()
  b_xy = Enum.at(parts, 1) |> parse_num_pair.()
  prize_xy = Enum.at(parts, 2) |> parse_num_pair.()
  {a_xy, b_xy, prize_xy}
end

machines = input |> String.split("\n\n")
  |> Enum.map(&parse_machine.(&1))

defmodule Part1 do
  def get_max_presses({button_x, button_y}, {prize_x, prize_y}) do
    max_x_presses = :math.floor(prize_x / button_x) |> trunc()
    max_y_presses = :math.floor(prize_y / button_y) |> trunc()
    Enum.min([max_x_presses, max_y_presses])
  end

  def get_valid_b_count([], _, _, _), do: nil
  def get_valid_b_count([count | rest], a_result = {ax_result, ay_result}, prize, {x_factor, y_factor}) do
    case {ax_result + count * x_factor, ay_result + count * y_factor} do
      ^prize -> count
      _ -> get_valid_b_count(rest, a_result, prize, {x_factor, y_factor})
    end
  end

  def get_valid_ab_counts(a_range, a_factors, b_range, b_factors, prize, acc \\ [])
  def get_valid_ab_counts([], _, _, _, _, acc), do: acc
  def get_valid_ab_counts([count | rest], a_factors = {ax_factor, ay_factor}, b_range, b_factors, prize, acc) do
    a_result = {ax_factor * count, ay_factor * count}

    valid_b_count = get_valid_b_count(b_range, a_result, prize, b_factors)
    acc = if valid_b_count != nil do
      [{count, valid_b_count} | acc]
    else
      acc
    end
    get_valid_ab_counts(rest, a_factors, b_range, b_factors, prize, acc)
  end

  def get_min_tokens(combinations, acc \\ nil)
  def get_min_tokens([], acc), do: acc
  def get_min_tokens([{a_pushes, b_pushes} | rest], acc) do
    score = 3 * a_pushes + b_pushes
    acc = if score < acc, do: score, else: acc
    get_min_tokens(rest, acc)
  end

  def get_machine_min_tokens(_machine = {a_factors, b_factors, prize}) do
    max_a = Part1.get_max_presses(a_factors, prize)
    max_b = Part1.get_max_presses(b_factors, prize)
    a_range = 0..max_a |> Range.to_list()
    b_range = 0..max_b |> Range.to_list()
    
    get_valid_ab_counts(a_range, a_factors, b_range, b_factors, prize)
      |> get_min_tokens()
  end
end

Enum.map(machines, &Part1.get_machine_min_tokens/1) |> Enum.filter(& &1) |> Enum.sum()

