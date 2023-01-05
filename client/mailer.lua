local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('keep-crafting:client:local_mailer', function(data)
    local msg = Lang:t('mail.message')
    local level = Lang:t('mail.level')
    local restricted = Lang:t('mail.no')
    if data.restricted then restricted = Lang:t('mail.yes') end
    msg = string.format(msg, data.gender, data.charinfo.lastname, data.item_name, data.success_rate, restricted,
        data.level)

    if data.level then
        level = string.format(level, data.level)
        msg = msg .. level
    end

    local mat = ''
    for name, amount in pairs(data.materials) do
        local _name = QBCore.Shared.Items[name]
        mat = mat .. " " .. string.format(Lang:t('mail.materials_list'), _name.label, amount)
    end
    msg = msg .. Lang:t('mail.materials_list_header') .. mat .. Lang:t('mail.tnx_message')
    TriggerServerEvent('qb-phone:server:sendNewMail', {
        sender = Lang:t('mail.sender'),
        subject = Lang:t('mail.subject'),
        message = msg,
        button = {}
    })
end)
