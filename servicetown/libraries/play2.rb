def play_options()
  return [default_play_options(), node[:play2][:options]].join(" ")
end

def default_play_options()
  options = []
  if node[:play2][:http_port]
    options << "-Dhttp.port=#{node[:play2][:http_port]}"
  end

  return options.join(" ")
end