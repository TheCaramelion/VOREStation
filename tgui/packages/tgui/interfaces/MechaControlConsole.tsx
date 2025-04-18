import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import {
  Box,
  Button,
  LabeledList,
  Modal,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { decodeHtmlEntities, toTitleCase } from 'tgui-core/string';

type Data = {
  beacons: {
    ref: string;
    charge: string;
    name: string;
    health: number;
    maxHealth: number;
    cell: string;
    cellCharge: number;
    cellMaxCharge: number;
    airtank: number;
    pilot: string;
    location: string;
    active: string | null;
    cargoUsed: number;
    cargoMax: number;
  }[];
  stored_data: { time: string; year: number; message: string }[];
};

export const MechaControlConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const { beacons = [], stored_data = [] } = data;
  return (
    <Window width={600} height={600}>
      <Window.Content scrollable>
        {stored_data.length ? (
          <Modal>
            <Section
              height="400px"
              style={{ overflowY: 'auto' }}
              title="Log"
              buttons={
                <Button icon="window-close" onClick={() => act('clear_log')} />
              }
            >
              {stored_data.map((data) => (
                <Box key={data.time}>
                  <Box color="label">
                    ({data.time}) ({data.year})
                  </Box>
                  <Box>{decodeHtmlEntities(data.message)}</Box>
                </Box>
              ))}
            </Section>
          </Modal>
        ) : (
          ''
        )}
        {(beacons.length &&
          beacons.map((beacon) => (
            <Section
              key={beacon.name}
              title={beacon.name}
              buttons={
                <Stack>
                  <Stack.Item>
                    <Button
                      icon="comment"
                      onClick={() => act('send_message', { mt: beacon.ref })}
                    >
                      Message
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="eye"
                      onClick={() => act('get_log', { mt: beacon.ref })}
                    >
                      View Log
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button.Confirm
                      color="red"
                      icon="bomb"
                      onClick={() => act('shock', { mt: beacon.ref })}
                    >
                      EMP
                    </Button.Confirm>
                  </Stack.Item>
                </Stack>
              }
            >
              <LabeledList>
                <LabeledList.Item label="Health">
                  <ProgressBar
                    ranges={{
                      good: [beacon.maxHealth * 0.75, Infinity],
                      average: [
                        beacon.maxHealth * 0.5,
                        beacon.maxHealth * 0.75,
                      ],
                      bad: [-Infinity, beacon.maxHealth * 0.5],
                    }}
                    value={beacon.health}
                    maxValue={beacon.maxHealth}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Cell Charge">
                  {(beacon.cell && (
                    <ProgressBar
                      ranges={{
                        good: [beacon.cellMaxCharge * 0.75, Infinity],
                        average: [
                          beacon.cellMaxCharge * 0.5,
                          beacon.cellMaxCharge * 0.75,
                        ],
                        bad: [-Infinity, beacon.cellMaxCharge * 0.5],
                      }}
                      value={beacon.cellCharge}
                      maxValue={beacon.cellMaxCharge}
                    />
                  )) || <NoticeBox>No Cell Installed</NoticeBox>}
                </LabeledList.Item>
                <LabeledList.Item label="Air Tank">
                  {beacon.airtank}kPa
                </LabeledList.Item>
                <LabeledList.Item label="Pilot">
                  {beacon.pilot || 'Unoccupied'}
                </LabeledList.Item>
                <LabeledList.Item label="Location">
                  {toTitleCase(beacon.location) || 'Unknown'}
                </LabeledList.Item>
                <LabeledList.Item label="Active Equipment">
                  {beacon.active || 'None'}
                </LabeledList.Item>
                {beacon.cargoMax ? (
                  <LabeledList.Item label="Cargo Space">
                    <ProgressBar
                      ranges={{
                        bad: [beacon.cargoMax * 0.75, Infinity],
                        average: [
                          beacon.cargoMax * 0.5,
                          beacon.cargoMax * 0.75,
                        ],
                        good: [-Infinity, beacon.cargoMax * 0.5],
                      }}
                      value={beacon.cargoUsed}
                      maxValue={beacon.cargoMax}
                    />
                  </LabeledList.Item>
                ) : (
                  ''
                )}
              </LabeledList>
            </Section>
          ))) || <NoticeBox>No mecha beacons found.</NoticeBox>}
      </Window.Content>
    </Window>
  );
};
