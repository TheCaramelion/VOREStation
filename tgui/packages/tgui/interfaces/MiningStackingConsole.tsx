import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import {
  AnimatedNumber,
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import { toTitleCase } from 'tgui-core/string';

type Data = {
  stacktypes: { type: string; amt: number }[];
  stackingAmt: number;
};

export const MiningStackingConsole = (props) => {
  const { act, data } = useBackend<Data>();

  const { stacktypes, stackingAmt } = data;

  return (
    <Window width={400} height={500}>
      <Window.Content>
        <Section title="Stacker Controls">
          <LabeledList>
            <LabeledList.Item label="Stacking">
              <NumberInput
                fluid
                step={1}
                value={stackingAmt}
                minValue={1}
                maxValue={50}
                stepPixelSize={5}
                onChange={(val) => act('change_stack', { amt: val })}
              />
            </LabeledList.Item>
            <LabeledList.Divider />
            {(stacktypes.length &&
              stacktypes.sort().map((stack) => (
                <LabeledList.Item
                  key={stack.type}
                  label={toTitleCase(stack.type)}
                  buttons={
                    <Button
                      icon="eject"
                      onClick={() =>
                        act('release_stack', { stack: stack.type })
                      }
                    >
                      Eject
                    </Button>
                  }
                >
                  <AnimatedNumber value={stack.amt} />
                </LabeledList.Item>
              ))) || (
              <LabeledList.Item label="Empty" color="average">
                No stacks in machine.
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
