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
end
