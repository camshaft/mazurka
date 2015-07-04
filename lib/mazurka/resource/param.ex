defmodule Mazurka.Resource.Param do
  defmacro param(name, opts \\ []) do
    Mazurka.Compiler.Utils.register(__MODULE__, name, opts)
  end

  @doc false
  def compile(params, _env) do
    IO.inspect {:params, params}
    []
  end

  @doc false
  def format(ast, type \\ :prop) do
    Macro.postwalk(ast, fn
      ({{:., meta, [{:__aliases__, _, [:Params]}, param]}, _, []}) when is_atom(param) ->
        case type do
          :prop ->
            {:etude_prop, meta, [param]}
          :conn ->
            param = param |> to_string
            quote do
              ^^Mazurka.Resource.Param.get_param(unquote(param))
            end
        end
      (node) ->
        node
    end)
  end

  @doc false
  def get_param([name], conn, _parent, _ref, _attrs) do
    params = Map.get(conn.private, :mazurka_params)
    val = Map.get(params, name)
    normalized = if val == nil, do: :undefined, else: URI.decode(val)
    {:ok, normalized}
  end
end