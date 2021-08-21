defmodule GitHubActions.Access do
  @moduledoc false

  def get(keywords, key, default) when is_atom(key) do
    Keyword.get(keywords, key, default)
  end

  def get(keywords, [key], default) when is_atom(key) do
    Keyword.get(keywords, key, default)
  end

  def get(keywords, [key | keys], default) when is_atom(key) do
    case Keyword.fetch(keywords, key) do
      {:ok, next} -> get(next, keys, default)
      :error -> default
    end
  end

  def fetch(keywords, key) when is_atom(key) do
    Keyword.fetch(keywords, key)
  end

  def fetch(keywords, [key]) when is_atom(key) do
    Keyword.fetch(keywords, key)
  end

  def fetch(keywords, [key | keys]) when is_atom(key) do
    with {:ok, next} <- Keyword.fetch(keywords, key) do
      fetch(next, keys)
    end
  end

  def fetch!(keywords, key) when is_atom(key) do
    Keyword.fetch!(keywords, key)
  end

  def fetch!(keywords, [key]) when is_atom(key) do
    Keyword.fetch!(keywords, key)
  end

  def fetch!(keywords, [key | keys]) when is_atom(key) do
    keywords |> Keyword.fetch!(key) |> fetch!(keys)
  end
end
