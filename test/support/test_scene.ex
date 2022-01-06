defmodule FloUI.Test.TestCase do
  defmacro __using__(opts \\ []) do
    quote do
      use ExUnit.Case, async: false

      alias Scenic.Graph
      alias Scenic.Scene
      alias Scenic.ViewPort.Input

      defmodule TestScene do
        use Scenic.Scene
        import Scenic.Components

        def graph() do
          graph = Graph.build()
          Enum.reduce(unquote(opts[:components]), graph, fn {module, data, opts}, acc ->
            module.add_to_graph(acc, data, opts)
          end)
        end

        @impl Scenic.Scene
        def init(scene, pid, opts) do
          scene =
            scene
            |> assign(pid: pid, sync_children?: unquote(opts[:sync_children?]) || false, theme: Scenic.Themes.normalize(opts[:theme]))
            |> push_graph(graph())

          Process.send(pid, {:up, scene}, [])
          {:ok, scene}
        end

        @impl Scenic.Scene
        def handle_event(event, _from, %{assigns: %{pid: pid}} = scene) do
          send(pid, event)
          {:noreply, scene}
        end
      end

      def send_input(vp, input) do
        Input.send(vp, input)
      end

      def send_input(vp, scene_pid, input) do
        Input.send(vp, input)
        force_sync(vp.pid, scene_pid)
      end

      def send_input(vp, scene_pid, child_pids, input) do
        Input.send(vp, input)
        force_sync(vp.pid, scene_pid, child_pids)
      end

      def get_child(scene, id) do
        case Scene.get_child(scene, id) do
          [child_scene | _] -> child_scene
          [] -> nil
        end
      end

      def get_primitive(scene, id) do
        case Graph.get(scene.assigns.graph, id) do
          [prim | _] -> prim
          [] -> nil
        end
      end

      def assert_data(prim, value) do
        assert prim.data == value
      end

      def assert_styles(prim, styles) do
        Enum.each(styles, fn {style, value} ->
          assert prim.styles[style] == value
        end)
      end

      def assert_assigns(scene, assigns) do
        Enum.each(assigns, fn {assign, value} ->
          assert scene.assigns[assign] == value
        end)
      end

      defp force_sync(vp_pid, scene_pid) do
        :_pong_ = GenServer.call(vp_pid, :_ping_)
        :_pong_ = GenServer.call(scene_pid, :_ping_)
        :_pong_ = GenServer.call(vp_pid, :_ping_)
      end

      defp get_scene_children(%Scene{} = scene) do
        if not is_nil(scene) and not is_nil(scene.children) do
          case Scene.children(scene) do
            {:ok, children} -> children
            {:error, :no_children} -> []
          end
        else
          []
        end
      end

      defp get_scene_children(scene) do
        []
      end

      defp build_sync_list(scene, id) when is_atom(id) do
        child_scene = get_child(scene, id)
        children = get_scene_children(scene)
        build_sync_list(scene, children)
      end

      defp build_sync_list(scene, children, acc \\ []) when is_list(children) do
        Enum.reduce(children, acc, fn {id, pid}, acc ->
          child_scene = get_child(scene, id)
          children = get_scene_children(child_scene)
          build_sync_list(child_scene, children, [pid | acc])
        end)
      end

      defp force_sync(vp_pid, scene_pid, child_pids) do
        :_pong_ = GenServer.call(vp_pid, :_ping_)
        Enum.each(child_pids, &GenServer.call(&1, :_ping_))
        :_pong_ = GenServer.call(scene_pid, :_ping_)
      end

      setup do
        out = FloUI.Test.ViewPort.start({TestScene, self()})
        # wait for a signal that the scene is up before proceeding
        {:ok, scene} =
          receive do
            {:up, scene} -> {:ok, scene}
          end

        # get the component being tested
        {:ok, [{id, pid}]} = Scene.children(scene)
        :_pong_ = GenServer.call(pid, :_ping_)

        # if this has deeply nested children let's build
        # a list of pids to keep them all in sync
        child_pids =
          if scene.assigns.sync_children? do
            build_sync_list(scene, id)
          else
            []
          end

        # sync all the children
        Enum.each(child_pids, &GenServer.call(&1, :_ping_))

        # needed to give time for the pid and vp to close
        on_exit(fn -> Process.sleep(1) end)

        out
        |> Map.put(:scene, scene)
        |> Map.put(:comp_pid, pid)
        |> Map.put(:child_pids, child_pids)
      end
    end
  end
end
