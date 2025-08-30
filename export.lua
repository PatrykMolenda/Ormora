return {
    Driver = Core.resolveDriver(),
    Model = require('core.model.base'),
    Builder = require('core.query.builder'),
    Migration = require('core.migration'),
    Grammar = require('core.query.grammar'),
    GitHub = require('core.util.github'),
    fs = require('core.util.fs'),
}