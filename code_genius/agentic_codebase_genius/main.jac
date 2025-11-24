walker analysis_status {
    has analysis_id:str;

    can check_status {
        let output_path = "./outputs/" + this.analysis_id;

        if std.fs.file_exists(output_path + "/COMPLETED") {
            emit status = "completed";
            # optionally read documentation
            let doc = std.fs.read(output_path + "/documentation.md");
            emit documentation = doc;
        } else if std.fs.file_exists(output_path + "/STARTED") {
            emit status = "in_progress";
        } else {
            emit status = "not_found";
        }
    }
}

walker serve_api {
    has port = 8080;

    can entry {
        std.http.server(port=port, cors=true);
        report "API running on port " + std.utils.to_str(port);
    }
}
