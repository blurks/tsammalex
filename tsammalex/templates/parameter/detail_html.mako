<%inherit file="../${context.get('request').registry.settings.get('clld.app_template', 'app.mako')}"/>
<%namespace name="util" file="../util.mako"/>
<%! active_menu_item = "parameters" %>
<%block name="title">${_('Parameter')} ${ctx.name} (${ctx.description})</%block>

<% dt = request.get_datatable('values', h.models.Value, parameter=ctx) %>
<% files = [f_ for f_ in ctx._files if f_.name.startswith('small') or f_.name.startswith('large')] %>
<div style="float: right; margin-top: 10px;">
    ${h.alt_representations(request, ctx, doc_position='left', exclude=['md.html'])}
</div>

<h2>${ctx.description or ctx.name}</h2>

<div class="row-fluid">
    <div class="span6">
<ul class="nav nav-pills">
    <li class="active"><a href="#map-container"><span class="icon-globe"> </span> Map</a></li>
    % if files:
        <li class="active"><a href="#images"><span class="icon-camera"> </span> Pictures</a></li>
    % endif
    <li class="active"><a href="#names"><span class="icon-list"> </span> Names</a></li>
</ul>
<table class="table table-condensed table-nonfluid">
    <tbody>
        <tr>
            <td>Biological classification:</td>
            <td>${u.format_classification(ctx, with_species=True, with_rank=True)|n}</td>
        </tr>
            % if ctx.characteristics:
                <tr>
                    <td>Characteristics:</td>
                    <td>${ctx.characteristics}</td>
                </tr>
            % endif
        <tr>
            <td>Countries:</td>
            <td>
                <ul class="unstyled">
                    % for c in ctx.countries:
                        <li>${c.name} (${c.id})</li>
                    % endfor
                </ul>
            </td>
        </tr>
        <tr>
            <td>
                <a href="${request.route_url('ecoregions')}">Ecoregions</a>:
            </td>
            <td>
                <ul class="unstyled">
                    % for er in ctx.ecoregions:
                    <li>${er.id} ${er.name}</li>
                    % endfor
                </ul>
            </td>
        </tr>
        <tr>
            <td>Links:</td>
            <td>
                <ul class="inline">
                    % if ctx.eol_url:
                        <li>
                <span class="large label label-info">
                    ${h.external_link(ctx.eol_url, 'eol', inverted=True, style="color: white;",)}
                </span>
                        </li>
                    % endif
                    % if ctx.wikipedia_url:
                        <li>
            <span class="large label label-info">
                ${h.external_link(ctx.wikipedia_url, 'wikipedia', inverted=True, style="color: white;")}
            </span>
                        </li>
                    % endif
                    % if ctx.tpl_url:
                        <li>
                <span class="large label label-info">
                    ${h.external_link(ctx.tpl_url, 'ThePlantList', inverted=True, style="color: white;",)}
                </span>
                        </li>
                    % endif
                </ul>
            </td>
        </tr>
        % if ctx.references:
            <tr>
                <td>References:</td>
                <td>${h.linked_references(request, ctx)}</td>
            </tr>
        % endif
    </tbody>
</table>
    </div>
    <div class="span6">
        ${request.get_map('parameter', col='lineage', dt=dt).render()}
    </div>
</div>

% for chunk in [files[i:i + 3] for i in range(0, len(files), 3)]:
<div class="row-fluid" id="images">
    % for f in chunk:
        <div class="span4">
            <div class="well">
                <img src="${request.file_url(f)}" class="image"/>
            </div>
            <table class="table table-condensed">
                <tbody>
                    % for attr in 'source date place author permission comments'.split():
                        % if f.jsondata.get(attr):
                            <% value = f.jsondata[attr] %>
                            <tr>
                                <td>${attr.capitalize()}:</td>
                                <td>
                                    % if attr == 'permission':
                                        % if value.get('license'):
                                        ${h.external_link(value['license'][0], value['license'][1])}
                                        % endif
                                    % elif attr == 'source':
                                        ${value|n}
                                    % else:
                                        ${value}
                                    % endif
                                </td>
                            </tr>
                        % endif
                    % endfor
                </tbody>
            </table>
        </div>
    % endfor
</div>
    <hr/>
% endfor

<div id="names">
${dt.render()}
</div>