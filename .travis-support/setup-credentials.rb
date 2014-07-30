#!/usr/bin/env ruby


def run(creds_csv)
  %w{AMAZON_ACCESS_KEY_ID AMAZON_SECRET_ACCESS_KEY}.zip(File::read(creds_csv).lines.last.split(",")[1..-1]).each do |key, value|
    %x"echo #{key}=#{value} | travis encrypt --org --add" #Perfect world: spawn the travis, pipe the secrets in
  end
end

run(*ARGV)
