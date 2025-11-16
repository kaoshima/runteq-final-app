class ToolsController < ApplicationController
  def validation_text
    # ビューを表示するだけ
  end

  def generate_validation_text
    char_count = params[:char_count].to_i
    char_type = params[:char_type]

    @char_count_results = []
    @char_type_results = []

    # 文字数が指定されている場合、境界値分析のテストデータを生成
    if char_count > 0
      # 有効値（指定文字数ちょうど）
      @char_count_results << {
        label: "有効（#{char_count}文字）",
        text: generate_text_by_count(char_count, char_type.presence || "hiragana")
      }

      # 無効値（指定文字数+1）
      @char_count_results << {
        label: "無効（#{char_count + 1}文字）",
        text: generate_text_by_count(char_count + 1, char_type.presence || "hiragana")
      }

      # 境界値-1（指定文字数-1）
      if char_count > 1
        @char_count_results << {
          label: "有効（#{char_count - 1}文字）",
          text: generate_text_by_count(char_count - 1, char_type.presence || "hiragana")
        }
      end
    end

    # 文字種が指定されている場合、有効・無効なテキストを生成
    if char_type.present?
      valid_text = generate_char_type_text(char_count > 0 ? char_count : 10, char_type)
      @char_type_results << {
        label: "有効な文字種（#{char_type_label(char_type)}）",
        text: valid_text
      }

      # 無効な文字種のサンプルを生成
      invalid_samples = generate_invalid_char_samples(char_count > 0 ? char_count : 10, char_type)
      @char_type_results.concat(invalid_samples)
    end

    respond_to do |format|
      format.turbo_stream
    end
  end

  def flexible_data
    # ビューを表示するだけ
  end

  def generate_flexible_data
    prefix = params[:prefix].to_s
    sequence_digits = params[:sequence_digits].to_i
    count = params[:count].to_i

    # バリデーション
    if count <= 0 || count > 1000
      @error = "生成する件数は1〜1000の範囲で指定してください"
      @generated_data = []
    elsif sequence_digits <= 0 || sequence_digits > 10
      @error = "連番の桁数は1〜10の範囲で指定してください"
      @generated_data = []
    else
      @generated_data = generate_sequence_data(prefix, sequence_digits, count)
      @error = nil
    end

    respond_to do |format|
      format.turbo_stream
    end
  end

  def simple_dummy
    # ビューを表示するだけ
  end

  def generate_name
    Faker::Config.locale = :ja
    @result = Faker::Name.name
    render_dummy_result("姓名", @result)
  end

  def generate_email
    @result = Faker::Internet.email
    render_dummy_result("メールアドレス", @result)
  end

  def generate_phone
    # テスト用の電話番号を生成（実在しない番号）
    # 日本の総務省が割り当てていない番号帯を使用
    # 020-で始まる番号は一部のみ使用されているため、テスト用として使用
    area_code = "020"
    exchange = rand(1000..9999)
    subscriber = rand(1000..9999)
    @result = "#{area_code}-#{exchange}-#{subscriber}"
    render_dummy_result("電話番号", @result)
  end

  def generate_address
    Faker::Config.locale = :ja
    prefecture = Faker::Address.state
    city = Faker::Address.city
    # 番地のみを生成（建物名や名前を含まない）
    building_number = Faker::Number.between(from: 1, to: 30)
    chome = Faker::Number.between(from: 1, to: 10)
    ban = Faker::Number.between(from: 1, to: 20)
    @result = "#{prefecture}#{city}#{chome}-#{ban}-#{building_number}"
    render_dummy_result("住所", @result)
  end

  def test_class_analysis
    # ビューを表示するだけ
  end

  def analyze_boundary
    min_value = params[:min_value].to_s.strip
    max_value = params[:max_value].to_s.strip

    # バリデーション
    if min_value.blank? || max_value.blank?
      @error = "下限値と上限値の両方を入力してください"
      @boundary_values = nil
      @equivalence_partitions = nil
    elsif !numeric?(min_value) || !numeric?(max_value)
      @error = "数値を入力してください"
      @boundary_values = nil
      @equivalence_partitions = nil
    elsif min_value.to_f >= max_value.to_f
      @error = "下限値は上限値より小さい値を入力してください"
      @boundary_values = nil
      @equivalence_partitions = nil
    else
      min = min_value.to_f
      max = max_value.to_f

      # 境界値分析
      @boundary_values = calculate_boundary_values(min, max)

      # 同値クラス分析
      @equivalence_partitions = calculate_equivalence_partitions(min, max)

      @error = nil
    end

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def generate_text_by_count(count, char_type)
    return "" if count <= 0

    case char_type
    when "hiragana"
      hiragana_chars = ("あ".."ん").to_a
      count.times.map { hiragana_chars.sample }.join
    when "katakana"
      katakana_chars = ("ア".."ン").to_a
      count.times.map { katakana_chars.sample }.join
    when "alphanumeric"
      alphanumeric_chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      count.times.map { alphanumeric_chars.sample }.join
    when "half_width_space"
      " " * count
    when "full_width_space"
      "　" * count
    else
      hiragana_chars = ("あ".."ん").to_a
      count.times.map { hiragana_chars.sample }.join
    end
  end

  def generate_char_type_text(count, char_type)
    return "" if count <= 0

    case char_type
    when "hiragana"
      hiragana_chars = ("あ".."ん").to_a
      count.times.map { hiragana_chars.sample }.join
    when "katakana"
      katakana_chars = ("ア".."ン").to_a
      count.times.map { katakana_chars.sample }.join
    when "alphanumeric"
      alphanumeric_chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      count.times.map { alphanumeric_chars.sample }.join
    when "half_width_space"
      " " * count
    when "full_width_space"
      "　" * count
    else
      ""
    end
  end

  def generate_invalid_char_samples(count, valid_char_type)
    samples = []

    case valid_char_type
    when "hiragana"
      katakana_chars = ("ア".."ン").to_a
      samples << {
        label: "無効な文字種（カタカナ）",
        text: count.times.map { katakana_chars.sample }.join
      }
      alphanumeric_chars = ("a".."z").to_a + ("A".."Z").to_a
      samples << {
        label: "無効な文字種（半角英数）",
        text: count.times.map { alphanumeric_chars.sample }.join
      }
    when "katakana"
      hiragana_chars = ("あ".."ん").to_a
      samples << {
        label: "無効な文字種（ひらがな）",
        text: count.times.map { hiragana_chars.sample }.join
      }
      alphanumeric_chars = ("a".."z").to_a + ("A".."Z").to_a
      samples << {
        label: "無効な文字種（半角英数）",
        text: count.times.map { alphanumeric_chars.sample }.join
      }
    when "alphanumeric"
      hiragana_chars = ("あ".."ん").to_a
      samples << {
        label: "無効な文字種（ひらがな）",
        text: count.times.map { hiragana_chars.sample }.join
      }
      symbol_chars = "!@#$%^&*()".chars
      samples << {
        label: "無効な文字種（記号）",
        text: count.times.map { symbol_chars.sample }.join
      }
    end

    samples
  end

  def char_type_label(char_type)
    case char_type
    when "hiragana" then "ひらがな"
    when "katakana" then "カタカナ"
    when "alphanumeric" then "半角英数"
    when "half_width_space" then "半角スペース"
    when "full_width_space" then "全角スペース"
    else ""
    end
  end

  def generate_sequence_data(prefix, digits, count)
    (1..count).map do |i|
      "#{prefix}#{i.to_s.rjust(digits, '0')}"
    end
  end

  def render_dummy_result(label, result)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "dummy-result-#{label}",
          partial: "tools/dummy_result",
          locals: { label: label, result: result, target_id: "dummy-result-#{label}" }
        )
      end
    end
  end

  def numeric?(value)
    true if Float(value) rescue false
  end

  def calculate_boundary_values(min, max)
    # 整数か小数かを判定
    is_integer = (min == min.to_i && max == max.to_i)

    if is_integer
      min = min.to_i
      max = max.to_i
      {
        valid_min: min,
        valid_min_plus_1: min + 1,
        valid_max_minus_1: max - 1,
        valid_max: max,
        invalid_min_minus_1: min - 1,
        invalid_max_plus_1: max + 1
      }
    else
      {
        valid_min: format_number(min),
        valid_min_plus_1: format_number(min + 0.01),
        valid_max_minus_1: format_number(max - 0.01),
        valid_max: format_number(max),
        invalid_min_minus_1: format_number(min - 0.01),
        invalid_max_plus_1: format_number(max + 0.01)
      }
    end
  end

  def calculate_equivalence_partitions(min, max)
    is_integer = (min == min.to_i && max == max.to_i)

    if is_integer
      min = min.to_i
      max = max.to_i
      middle = (min + max) / 2

      {
        invalid_below: {
          label: "無効（下限未満）",
          example: min - 10
        },
        valid: {
          label: "有効（範囲内）",
          example: middle
        },
        invalid_above: {
          label: "無効（上限超過）",
          example: max + 10
        }
      }
    else
      middle = (min + max) / 2.0

      {
        invalid_below: {
          label: "無効（下限未満）",
          example: format_number(min - 10.0)
        },
        valid: {
          label: "有効（範囲内）",
          example: format_number(middle)
        },
        invalid_above: {
          label: "無効（上限超過）",
          example: format_number(max + 10.0)
        }
      }
    end
  end

  def format_number(num)
    num.to_s.include?(".") ? num.round(2) : num.to_i
  end
end
