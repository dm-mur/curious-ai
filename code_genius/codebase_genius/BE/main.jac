import supervisor.jac;
import repo_mapper.jac;

walker Main {
    can start;

    has url: str;

    start {
        # Call the supervisor to orchestrate the workflow
        call CodeGeniusSupervisor.orchestrate_workflow(url) -> output_path;
        return output_path;
    }
}
