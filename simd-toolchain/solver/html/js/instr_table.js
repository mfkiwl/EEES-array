var selected_instr;
function get_producer_user(st) {
    var users = [];
    var producers = [];
    var parts = st.split('|');
    if (parts.length == 2) {
        var u_s = parts[0].split(';');
        var p_s = parts[1].split(';');
        for (var i = 0; i < u_s.length; ++i) {
            if (u_s[i]) {
                var ts = u_s[i].split(',');
                if (ts.length == 2) {
                    var u = {time:parseInt(ts[0]), issue:parseInt(ts[1])};
                    users.push(u);
                }
            }
        }
        
        for (var i = 0; i < p_s.length; ++i) {
            if (p_s[i]) {
                var ts = p_s[i].split(',');
                if (ts.length == 2) {
                    var p = {time:parseInt(ts[0]), issue:parseInt(ts[1])};
                    producers.push(p);
                }
            }
        }
    }
    return {producers:producers, users:users};
}

function get_bb_id(cell_id) {
    var bidx = cell_id.indexOf(".");
    return parseInt(cell_id.substring(1, bidx));
}

function get_cell_id(bb, op) {
    return "b"+bb+"."+op.time+"."+op.issue;
}

function select_cell(cid) {
    cell = $(document.getElementById(cid));
    cell.addClass("selected_instr");
    var st = cell.children("span").first().text();
    var pu  = get_producer_user(st);
    var bid = get_bb_id(cid);
    for (var i = 0; i < pu.producers.length; ++i) {
        var pid = get_cell_id(bid, pu.producers[i]);
        $(document.getElementById(pid)).addClass("selected_producer");
    }
    var last_use = -1;
    for (var i = 0; i < pu.users.length; ++i) {
        var uid = get_cell_id(bid, pu.users[i]);
        $(document.getElementById(uid)).addClass("selected_user");
        last_use = Math.max(pu.users[i].time, last_use);
    }
    selected_instr = cid;
    var cell_cont = cell.clone();
    cell_cont.find('span').remove();
    $(document.getElementById("op_asm")).text(cell_cont.text());
    var tp = cid.split('.');
    $(document.getElementById("op_time")).text(tp[0]+'.'+tp[1]);
    var cell_spans = cell.children("span")
    var val = parseInt(cell_spans.eq(1).text());
    if (val >= 0) {
        $(document.getElementById("op_value")).text(val);
    } else {
        $(document.getElementById("op_value")).text("--");
    }
    $(document.getElementById("op_latency")).text(cell_spans.eq(2).text());
    if (last_use >= 0) {
        $(document.getElementById("op_lastuse"))
            .text(pu.users.length+" time(s), last at "+ last_use);
    } else {
        $(document.getElementById("op_lastuse")).text("--");
    }
}

function unselect_cell(cid) {
    cell = $(document.getElementById(cid));
    cell.removeClass("selected_instr");
    var st = cell.children("span").first().text();
    var pu  = get_producer_user(st);
    var bid = get_bb_id(cid);
    for (var i = 0; i < pu.producers.length; ++i) {
        var pid = get_cell_id(bid, pu.producers[i]);
        $(document.getElementById(pid)).removeClass("selected_producer");
    }
    for (var i = 0; i < pu.users.length; ++i) {
        var uid = get_cell_id(bid, pu.users[i]);
        $(document.getElementById(uid)).removeClass("selected_user");
    }
    if (selected_instr == cid) {
        selected_instr = null;
    }
    $(document.getElementById("op_asm")).text("--");
    $(document.getElementById("op_time")).text("--");
    $(document.getElementById("op_value")).text("--");
    $(document.getElementById("op_latency")).text("--");
    $(document.getElementById("op_lastuse")).text("--");
}

$('.instr_grid').click(function(evt) {
        var cell= $(evt.target); //Get the cell
        if (cell.hasClass("issue_op")) {
            var cid = cell.attr('id');
            if (cid == selected_instr) {
                unselect_cell(cid);
            } else {
                if (selected_instr) {
                    unselect_cell(selected_instr);
                }
                select_cell(cid);
            }
        }
        evt.preventDefault();
    });

$('#goto_op').click(function(evt) {
        if (selected_instr) {
            var cell = $(document.getElementById(selected_instr));
            cell.get(0).scrollIntoView();
        }
        evt.preventDefault();
    });

$('#clear_op').click(function(evt) {
        if (selected_instr) {
            unselect_cell(selected_instr);
        }
        evt.preventDefault();
    });