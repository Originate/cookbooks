def play_url()
  if port = node[:play2][:https_port]
    protocol = "https"
  else
    port = node[:play2][:http_port] || 9000
    protocol = "http"
  end

  return "#{protocol}://localhost:#{port.to_s}"
end

def play_options()
  return [default_play_options(), node[:play2][:options]].compact.join(" ")
end

def default_play_options()
  options = []

  if node[:play2][:http_port]
    options << "-Dhttp.port=#{node[:play2][:http_port]}"
  end
  if node[:play2][:https_port]
    options << "-Dhttps.port=#{node[:play2][:https_port]}"
  end

  if node[:play2][:app_conf_file]
    options << "-Dconfig.file=#{node[:play2][:app_conf_file]}"
  end

  if node[:play2][:log_conf_file]
    options << "-Dlogger.file=#{node[:play2][:log_conf_file]}"
  end

  return options.join(" ")
end

def play_flat_config(config, prefix = nil)
  flat_config = {}
  config.each_pair do |key, val|
    flat_key = [prefix, key].compact.join('.')

    if val.is_a?(Hash)
      flat_config.merge!(play_flat_config(val, flat_key))
    else
      flat_config[flat_key] = val
    end
  end
  flat_config
end